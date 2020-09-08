pragma solidity ^0.5.10;

import "./SupplyChainStorageOwnable.sol";

contract SupplyChainStorage is SupplyChainStorageOwnable {
    
    address public lastAccess;
    constructor() public {
        authorizedCaller[msg.sender] = 1;
        emit AuthorizedCaller(msg.sender);
    }
    
    /* Events */
    event AuthorizedCaller(address caller);
    event DeAuthorizedCaller(address caller);
    
    /* Modifiers */
    
    modifier onlyAuthCaller(){
        lastAccess = msg.sender;
        require(authorizedCaller[msg.sender] == 1);
        _;
    }
    
    /* User Related */
    struct user {
        string name;
        string contactNo;
        bool isActive;
        string profileHash;
    } 
    
    mapping(address => user) userDetails;
    mapping(address => string) userRole;
    
    /* Caller Mapping */
    mapping(address => uint8) authorizedCaller;
    
    /* authorize caller */
    function authorizeCaller(address _caller) public onlyOwner returns(bool) 
    {
        authorizedCaller[_caller] = 1;
        emit AuthorizedCaller(_caller);
        return true;
    }
    
    /* deauthorize caller */
    function deAuthorizeCaller(address _caller) public onlyOwner returns(bool) 
    {
        authorizedCaller[_caller] = 0;
        emit DeAuthorizedCaller(_caller);
        return true;
    }
    
    /*User Roles
        SUPER_ADMIN,
        FARMER,
        MANUFACTURER,
        DISTRIBUTOR,
        RETAILER
    */
    
    /* Process Related */
     struct basicDetails {
        string registrationNo;
        string farmerName;
        string farmAddress;
        string manufacturerName;
        string distributorName;
        
    }
    
    struct farmer {
        string cropVariety;
        string temperatureUsed;
        string humidity;
    }    
    
    struct manufacturer {
        string destinationAddress;
        string shipName;
        string shipNo;
        uint256 quantity;
        uint256 departureDateTime;
        uint256 estimateDateTime;
        uint256 plantNo;
        uint256 manufacturerId;
    }
    
    struct distributor {
        uint256 quantity;
        uint256 arrivalDateTime;
        uint256 distributorId;
        string shipName;
        string shipNo;
        string warehouseName;
        string warehouseAddress;
    }
    
    struct retailer {
        uint256 quantity;
        uint256 packageDateTime;
        string temperature;
        string internalBatchNo;
        string retailerName;
        string retailerAddress;
    }
    
    mapping (address => basicDetails) batchBasicDetails;
    mapping (address => farmer) batchFarmer;
    mapping (address => manufacturer) batchManufacturer;
    mapping (address => distributor) batchDistributor;
    mapping (address => retailer) batchRetailer;
    mapping (address => string) nextAction;
    
    /*Initialize struct pointer*/
    user userDetail;
    basicDetails basicDetailsData;
    farmer farmerData;
    manufacturer manufacturerData;
    distributor distributorData;
    retailer retailerData; 
    
    
    
    /* Get User Role */
    function getUserRole(address _userAddress) public onlyAuthCaller payable returns(string memory)
    {
        return userRole[_userAddress];
    }
    
    /* Get Next Action  */    
    function getNextAction(address _batchNo) public onlyAuthCaller payable returns(string memory)
    {
        return nextAction[_batchNo];
    }
        
    /*set user details*/
    function setUser(address _userAddress,
                     string memory _name, 
                     string memory _contactNo, 
                     string memory _role, 
                     bool _isActive,
                     string memory _profileHash) public onlyAuthCaller returns(bool){
        
        /*store data into struct*/
        userDetail.name = _name;
        userDetail.contactNo = _contactNo;
        userDetail.isActive = _isActive;
        userDetail.profileHash = _profileHash;
        
        /*store data into mapping*/
        userDetails[_userAddress] = userDetail;
        userRole[_userAddress] = _role;
        
        return true;
    }  
    
    /*get user details*/
    function getUser(address _userAddress) public onlyAuthCaller payable returns(string memory name, 
                                                                    string memory contactNo, 
                                                                    string memory role,
                                                                    bool isActive, 
                                                                    string memory profileHash
                                                                ){

        /*Getting value from struct*/
        user memory tmpData = userDetails[_userAddress];
        
        return (tmpData.name, tmpData.contactNo, userRole[_userAddress], tmpData.isActive, tmpData.profileHash);
    }
    
    /*get batch basicDetails*/
    function getBasicDetails(address _batchNo) public onlyAuthCaller payable returns(string memory registrationNo,
                             string memory farmerName,
                             string memory farmAddress,
                             string memory manufacturerName,
                             string memory distributorName) {
        
        basicDetails memory tmpData = batchBasicDetails[_batchNo];
        
        return (tmpData.registrationNo,tmpData.farmerName,tmpData.farmAddress,tmpData.manufacturerName,tmpData.distributorName);
    }
    
    /*set batch basicDetails*/
    function setBasicDetails(string memory _registrationNo,
                             string memory _farmerName,
                             string memory _farmAddress,
                             string memory _manufacturerName,
                             string memory _distributorName
                             
                            ) public onlyAuthCaller returns(address) {
        
        uint tmpData = uint(keccak256(abi.encodePacked(msg.sender, now)));
        address batchNo = address(tmpData);
        
        basicDetailsData.registrationNo = _registrationNo;
        basicDetailsData.farmerName = _farmerName;
        basicDetailsData.farmAddress = _farmAddress;
        basicDetailsData.manufacturerName = _manufacturerName;
        basicDetailsData.distributorName = _distributorName;
        
        batchBasicDetails[batchNo] = basicDetailsData;
        
        nextAction[batchNo] = 'FARMER';   
        
        
        return batchNo;
    }

    
    /*set Farmer data*/
    function setFarmerData(address batchNo,
                              string memory _cropVariety,
                              string memory _temperatureUsed,
                              string memory _humidity) public onlyAuthCaller returns(bool){
        farmerData.cropVariety = _cropVariety;
        farmerData.temperatureUsed = _temperatureUsed;
        farmerData.humidity = _humidity;
        
        batchFarmer[batchNo] = farmerData;
        
        nextAction[batchNo] = 'MANUFACTURER'; 
        
        return true;
    }
    
    /*get farmer data*/
    function getFarmerData(address batchNo) public onlyAuthCaller payable returns(string memory cropVariety,
                                                                                           string memory temperatureUsed,
                                                                                           string memory humidity){
        
        farmer memory tmpData = batchFarmer[batchNo];
        return (tmpData.cropVariety, tmpData.temperatureUsed, tmpData.humidity);
    }
    
    /*set Mnaufacturer data*/
    function setManufacturerData(address batchNo,
                              uint256 _quantity,    
                              string memory _destinationAddress,
                              string memory _shipName,
                              string memory _shipNo,
                              uint256 _estimateDateTime,
                              uint256 _manufacturerId) public onlyAuthCaller returns(bool){
        
        manufacturerData.quantity = _quantity;
        manufacturerData.destinationAddress = _destinationAddress;
        manufacturerData.shipName = _shipName;
        manufacturerData.shipNo = _shipNo;
        manufacturerData.departureDateTime = now;
        manufacturerData.estimateDateTime = _estimateDateTime;
        manufacturerData.manufacturerId = _manufacturerId;
        
        batchManufacturer[batchNo] = manufacturerData;
        
        nextAction[batchNo] = 'DISTRIBUTOR'; 
        
        return true;
    }
    
    /*get Manufacturer data*/
    function getManufacturerData(address batchNo) public onlyAuthCaller payable returns(uint256 quantity,
                                                                string memory destinationAddress,
                                                                string memory shipName,
                                                                string memory shipNo,
                                                                uint256 departureDateTime,
                                                                uint256 estimateDateTime,
                                                                uint256 manfacturerId){
        
        
        manufacturer memory tmpData = batchManufacturer[batchNo];
        
        
        return (tmpData.quantity, 
                tmpData.destinationAddress, 
                tmpData.shipName, 
                tmpData.shipNo, 
                tmpData.departureDateTime, 
                tmpData.estimateDateTime, 
                tmpData.manufacturerId);
                
        
    }

    
    /*set Distributor data*/
    function setDistributorData(address batchNo,
                              uint256 _quantity, 
                              string memory _shipName,
                              string memory _shipNo,
                              string memory _warehouseName,
                              string memory _warehouseAddress,
                              uint256 _distributorId) public onlyAuthCaller returns(bool){
        
        distributorData.quantity = _quantity;
        distributorData.shipName = _shipName;
        distributorData.shipNo = _shipNo;
        distributorData.arrivalDateTime = now;
        distributorData.warehouseName = _warehouseName;
        distributorData.warehouseAddress = _warehouseAddress;
        distributorData.distributorId = _distributorId;
        
        batchDistributor[batchNo] = distributorData;
        
        nextAction[batchNo] = 'RETAILER'; 
        
        return true;
    }
    
    /*get Distributor data*/
    function getDistributorData(address batchNo) public onlyAuthCaller payable returns(uint256 quantity,
                                                                                        string memory shipName,
                                                                                        string memory shipNo,
                                                                                        uint256 arrivalDateTime,
                                                                                        string memory warehouseName,
                                                                                        string memory warehouseAddress,
                                                                                        uint256 distributorId){
        
        distributor memory tmpData = batchDistributor[batchNo];
        
        
        return (tmpData.quantity, 
                tmpData.shipName, 
                tmpData.shipNo, 
                tmpData.arrivalDateTime,
                tmpData.warehouseName,
                tmpData.warehouseAddress,
                tmpData.distributorId);
                
        
    }

    /*set Retailer data*/
    function setRetailerData(address batchNo,
                              uint256 _quantity, 
                              string memory _temperature,
                              string memory _internalBatchNo,
                              uint256 _packageDateTime,
                              string memory _retailerName,
                              string memory _retailerAddress) public onlyAuthCaller returns(bool){
        
        
        retailerData.quantity = _quantity;
        retailerData.temperature = _temperature;
        retailerData.internalBatchNo = _internalBatchNo;
        retailerData.packageDateTime = _packageDateTime;
        retailerData.retailerName = _retailerName;
        retailerData.retailerAddress = _retailerAddress;
        
        batchRetailer[batchNo] = retailerData;
        
        nextAction[batchNo] = 'DONE'; 
        
        return true;
    }
    
    
    /*get Retailer data*/
    function getRetailerData( address batchNo) public onlyAuthCaller payable returns(
                                                                                        uint256 quantity,
                                                                                        string memory temperature,
                                                                                        string memory internalBatchNo,
                                                                                        uint256 packageDateTime,
                                                                                        string memory retailerName,
                                                                                        string memory retailerAddress){

        retailer memory tmpData = batchRetailer[batchNo];
        
        
        return (
                tmpData.quantity, 
                tmpData.temperature, 
                tmpData.internalBatchNo,
                tmpData.packageDateTime,
                tmpData.retailerName,
                tmpData.retailerAddress);
                
        
    }
  
}    