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
    
    // Total Staking Pool (doesnt include rewards, represents total shares)
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
        // check if we are already nominating
        if (staking.is_nominator(address(this))) {
            staking.nominator_bond_more(target, msg.value);
        }
        else {
            if(address(this).balance < MinNominatorStk){
                revert("Balance is less than minimum nomination amount.");
            } else {
                //initialiate the nomination
                staking.nominate(target, address(this).balance, staking.collator_nomination_count(target), staking.nominator_nomination_count(address(this)));
            }
        }
    }

    // Function for a user to cash out
    function cash_out(address payable account) public onlyRole(MEMBER) {
        //minimum amount returned
        uint amount = memberStakes[msg.sender];
        uint stakingRewards = 0;
        if (address(this).balance != 0){
            stakingRewards = address(this)
            .balance
            .mul(memberStakes[msg.sender])
            .div(totalStake);
        }
        if ((totalStake - memberStakes[msg.sender]) >= MinNominatorStk){
                staking.nominator_bond_less(target, memberStakes[msg.sender]); 
                Address.sendValue(account, amount + stakingRewards);
                totalStake = totalStake.sub(memberStakes[msg.sender]);
                memberStakes[msg.sender] = 0;
        } else{
            staking.revoke_nomination(target);
        }
    }
    
    function retrieve_revoked_cash(address payable account) public onlyRole(MEMBER){
        uint stakingRewards = (address(this).balance - memberStakes[msg.sender])
        .mul(memberStakes[msg.sender])
        .div(totalStake);
        require(address(this).balance >= memberStakes[msg.sender]+stakingRewards, "Not enough free balance!");
        Address.sendValue(account, memberStakes[msg.sender]+stakingRewards);
        totalStake = totalStake.sub(memberStakes[msg.sender]);
        memberStakes[msg.sender] = 0;
    }
    
    //Check how much free balance the DAO currently has. It should be the staking rewards. 
    function check_free_balance() public view onlyRole(MEMBER) returns(uint256){
        return address(this).balance;
    }
    
    function change_target(address newCollator) public onlyRole(DEFAULT_ADMIN_ROLE){
        target = newCollator;
    }


}