// SPDX-License-Identifier: GPL-3.0-only
// This is a PoC to use the staking precompile wrapper as a Solidity developer.
pragma solidity >=0.8.0;

import "./StakingInterface.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract NominationDAO is AccessControl {
    using SafeMath for uint256;
    
    // Role definition for contract members (approved by admin)
    bytes32 public constant MEMBER = keccak256("MEMBER");

    // Member stakes (doesnt include rewards, represents member shares)
    mapping(address => uint256) public memberStakes;
    
    // Total Stake (doesnt include rewards, represents total shares)
    uint256 public totalStake;

    /// The ParachainStaking wrapper at the known pre-compile address. This will be used to make
    /// all calls to the underlying staking solution
    ParachainStaking public staking;
    
    // TODO Our interface should have an accessor for this.
    uint256 public constant MinNominatorStk = 5 ether;

    /// The collator that this DAO is currently nominating
    address public target;

    /// Initialize a new NominationDao dedicated to nominating the given collator target.
    constructor(address _target, address admin) {
        
        //Sets the collator that this DAO nominating
        target = _target;
        
        // Initializes Moonbeam's parachain staking precompile
        staking = ParachainStaking(0x0000000000000000000000000000000000000800);
        
        //Initializes Roles
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(MEMBER, admin);
        
    }

    // Grant a user the role of admin
    function grant_admin(address newAdmin)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
        onlyRole(MEMBER)
    {
        grantRole(DEFAULT_ADMIN_ROLE, newAdmin);
        grantRole(MEMBER, newAdmin);
    }

    // Grant a user membership
    function grant_member(address newMember)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        grantRole(MEMBER, newMember);
    }

    // Revoke a user membership
    function remove_member(address payable exMember)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        cash_out(exMember);
        revokeRole(MEMBER, exMember);
    }

    // Add stake (and increase pool share)
    function add_stake() external payable onlyRole(MEMBER) {
        memberStakes[msg.sender] = memberStakes[msg.sender].add(msg.value);
        totalStake = totalStake.add(msg.value);
    }

    // Function for a user to cash out
    function cash_out(address payable account) public onlyRole(MEMBER) {
        uint256 amount = address(this)
        .balance
        .mul(memberStakes[msg.sender])
        .div(totalStake);
        Address.sendValue(account, amount);
        totalStake = totalStake.sub(memberStakes[msg.sender]);
        memberStakes[msg.sender] = 0;
    }

    /// Update the on-chain nomination to reflect any recently-contributed nominations.
    function update_nomination(address _target) public onlyRole(DEFAULT_ADMIN_ROLE)  {
        // If we are already nominating, we need to remove the old nomination first
        if (staking.is_nominator(address(this))) {
            staking.revoke_nomination(target);
        }
        target = _target;
        // If we have enough funds to nominate, we should start a nomination
        if (address(this).balance > MinNominatorStk) {

            staking.nominate(target, address(this).balance, staking.collator_nomination_count(target), staking.nominator_nomination_count(address(this)));
        } else {
            revert("NominationBelowMin");
        }
    }
    
    
    
    //Unstake this amount, there is a waiting period
    function unstake() public onlyRole(MEMBER) {
        staking.nominator_bond_less(target, memberStakes[msg.sender]);
    }
    
    function check_free_balance() public view onlyRole(MEMBER) returns(uint256){
        return address(this).balance;
    }

    /// Calls directly into the interface.
    /// Assumes the contract has atleast 10 ether so that the nomination will be successful.
    function unsafe_attempt_to_nominate() public onlyRole(DEFAULT_ADMIN_ROLE)  {
        staking.nominate(target, address(this).balance, staking.collator_nomination_count(target), staking.nominator_nomination_count(address(this)));
    }

    // We need a public receive function to accept ether donations as direct transfers
    // https://blog.soliditylang.org/2020/03/26/fallback-receive-split/
    //receive() external payable {
        // It would be nice to call update_nomination here so it happens automatically.
        // but there is very little gas available when just sending a normal transfer.
        // So instead we rely on manually calling update_nomination
    //}
}