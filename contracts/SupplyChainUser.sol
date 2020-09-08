pragma solidity ^0.5.10;
import "./SupplyChainStorage.sol";
import "./Ownable.sol";

contract SupplyChainUser is Ownable
{
     /*Events*/ 
    event UserUpdate(address indexed user, string name, string contactNo, string role, bool isActive, string profileHash);
    event UserRoleUpdate(address indexed user, string role); 
    
     /* Storage Variables */    
    SupplyChainStorage supplyChainStorage;
    
    constructor(address _supplyChainAddress) public {
        supplyChainStorage = SupplyChainStorage(_supplyChainAddress);
    }
    
    
     /* Create/Update User */

    function updateUser(string memory _name, string memory _contactNo, string memory _role, bool _isActive,string memory _profileHash) public returns(bool)
    {
        require(msg.sender != address(0));
        
        /* Call Storage Contract */
        bool status = supplyChainStorage.setUser(msg.sender, _name, _contactNo, _role, _isActive,_profileHash);
        
         /*call event*/
        emit UserUpdate(msg.sender,_name,_contactNo,_role,_isActive,_profileHash);
        emit UserRoleUpdate(msg.sender,_role);
        
        return status;
    }
    
    /* Create/Update User For Admin  */
    function updateUserForAdmin(address _userAddress, string memory _name, string memory _contactNo, string memory _role, bool _isActive,string memory _profileHash) public onlyOwner returns(bool)
    {
        require(_userAddress != address(0));
        
        /* Call Storage Contract */
        bool status = supplyChainStorage.setUser(_userAddress, _name, _contactNo, _role, _isActive, _profileHash);
        
         /*call event*/
        emit UserUpdate(_userAddress,_name,_contactNo,_role,_isActive,_profileHash);
        emit UserRoleUpdate(_userAddress,_role);
        
        return status;
    }
    
    /* get User */
    function getUser(address _userAddress) public payable returns(string memory name, string memory contactNo, string memory role, bool isActive , string memory profileHash){
        require(_userAddress != address(0));
        
        /*Getting value from struct*/
       (name, contactNo, role, isActive, profileHash) = supplyChainStorage.getUser(_userAddress);
       
       return (name, contactNo, role, isActive, profileHash);
    }
}