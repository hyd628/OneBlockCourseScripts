// SPDX-License-Identifier: GPL-3.0-only
// This is a PoC to use the staking precompile wrapper as a Solidity developer.
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract NominationDAOPayable is AccessControl {
    using SafeMath for uint256;

    // Role definition for contract members (approved by admin)
    bytes32 public constant MEMBER = keccak256("MEMBER");
    
    // Member stakes (doesnt include rewards, represents member shares)
    mapping(address => uint256) public memberStakes;
    
    // Total Stake (doesnt include rewards, represents total shares)
    uint256 public totalStake;

    /// Initialize a new NominationDao dedicated to nominating the given collator target.
    constructor(address admin) {
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
    
}