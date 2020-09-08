pragma solidity ^0.5.10;
import "./SupplyChainStorage.sol";
import "./Ownable.sol";

contract CoffeeSupplyChain is Ownable
{
  
    event PerformCultivation(address indexed user, address indexed batchNo);
    event DoneFarming(address indexed user, address indexed batchNo);
    event DoneManufacturing(address indexed user, address indexed batchNo);
    event DoneDistributing(address indexed user, address indexed batchNo);
    event DoneRetailing(address indexed user, address indexed batchNo);

    
    /*Modifier*/
    modifier isValidPerformer(address batchNo, string memory role) {
    
        require(keccak256(abi.encodePacked(supplyChainStorage.getUserRole(msg.sender))) == keccak256(abi.encodePacked(role)));
        require(keccak256(abi.encodePacked(supplyChainStorage.getNextAction(batchNo))) == keccak256(abi.encodePacked(role)));
        _;
    }
    
    /* Storage Variables */    
    SupplyChainStorage supplyChainStorage;
    
    constructor(address _supplyChainAddress) public {
        supplyChainStorage = SupplyChainStorage(_supplyChainAddress);
    }
    
    
    /* Get Next Action  */    

    function getNextAction(address _batchNo) public returns(string memory action)
    {
       (action) = supplyChainStorage.getNextAction(_batchNo);
       return (action);
    }
    

    /* get Basic Details */
    
    function getBasicDetails(address _batchNo) public returns (string memory registrationNo,
                                                                     string memory farmerName,
                                                                     string memory farmAddress,
                                                                     string memory manufacturerName,
                                                                     string memory distributorName) {
        /* Call Storage Contract */
        (registrationNo, farmerName, farmAddress, manufacturerName, distributorName) = supplyChainStorage.getBasicDetails(_batchNo);  
        return (registrationNo, farmerName, farmAddress, manufacturerName, distributorName);
    }

    /* perform Basic Cultivation */
    
    function addBasicDetails(string memory _registrationNo,
                             string memory _farmerName,
                             string memory _farmAddress,
                             string memory _manufacturerName,
                             string memory _distributorName
                            ) public payable onlyOwner returns(address) {
    
        address batchNo = supplyChainStorage.setBasicDetails(_registrationNo,
                                                            _farmerName,
                                                            _farmAddress,
                                                            _manufacturerName,
                                                            _distributorName);
        
        emit PerformCultivation(msg.sender, batchNo); 
        
        return (batchNo);
    }                            
    
    /* get Farming */
    
    function getFarmerData(address _batchNo) public returns (string memory cropVariety, string memory temperatureUsed, string memory humidity) {
        /* Call Storage Contract */
        (cropVariety, temperatureUsed, humidity) =  supplyChainStorage.getFarmerData(_batchNo);  
        return (cropVariety, temperatureUsed, humidity);
    }
    
    /* perform Farming */
    
    function updateFarmerData(address _batchNo,
                                string memory _cropVariety,
                                string memory _temperatureUsed,
                                string memory _humidity) 
                                public payable isValidPerformer(_batchNo,'FARMER') returns(bool) {
                                    
        /* Call Storage Contract */
        bool status = supplyChainStorage.setFarmerData(_batchNo, _cropVariety, _temperatureUsed, _humidity);  
        
        emit DoneFarming(msg.sender, _batchNo);
        return (status);
    }
    
    /* get Manufacture */
    
    function getManufacturerData(address _batchNo) public returns (uint256 quantity,
                                                                    string memory destinationAddress,
                                                                    string memory shipName,
                                                                    string memory shipNo,
                                                                    uint256 departureDateTime,
                                                                    uint256 estimateDateTime,
                                                                    uint256 manufacturerId) {
        /* Call Storage Contract */
       (quantity,
        destinationAddress,
        shipName,
        shipNo,
        departureDateTime,
        estimateDateTime,
        manufacturerId) =  supplyChainStorage.getManufacturerData(_batchNo);  
        
        return (quantity,
                destinationAddress,
                shipName,
                shipNo,
                departureDateTime,
                estimateDateTime,
                manufacturerId);
    }
    
    /* perform Manufacture */
    
    function updateManufacturerData(address _batchNo,
                                uint256 _quantity,    
                                string memory _destinationAddress,
                                string memory _shipName,
                                string memory _shipNo,
                                uint256 _estimateDateTime,
                                uint256 _manufacturerId) 
                                public payable isValidPerformer(_batchNo,'MANUFACTURER') returns(bool) {
                                    
        /* Call Storage Contract */
        bool status = supplyChainStorage.setManufacturerData(_batchNo, _quantity, _destinationAddress, _shipName,_shipNo, _estimateDateTime,_manufacturerId);  
        
        emit DoneManufacturing(msg.sender, _batchNo);
        return (status);
    }
    
    /* get Distribution */
    
    function getDistributorData(address _batchNo) public returns (uint256 quantity,
                                                                    string memory shipName,
                                                                    string memory shipNo,
                                                                    uint256 arrivalDateTime,
                                                                    string memory warehouseName,
                                                                    string memory warehouseAddress,
                                                                    uint256 distributorId) {
        /* Call Storage Contract */
        (quantity,
         shipName,
         shipNo,
         arrivalDateTime,
         warehouseName,
         warehouseAddress,
         distributorId) =  supplyChainStorage.getDistributorData(_batchNo);  
         
         return (quantity,
                 shipName,
                 shipNo,
                 arrivalDateTime,
                 warehouseName,
                 warehouseAddress,
                 distributorId);
        
    }
    
    /* perform Distribution */
    
    function updateDistributorData(address _batchNo,
                                uint256 _quantity, 
                                string memory _shipName,
                                string memory _shipNo,
                                string memory _warehouseName,
                                string memory _warehouseAddress,
                                uint256 _distributorId) 
                                public payable isValidPerformer(_batchNo,'DISTRIBUTOR') returns(bool) {
                                    
        /* Call Storage Contract */
        bool status = supplyChainStorage.setDistributorData(_batchNo, _quantity, _shipName, _shipNo, _warehouseName,_warehouseAddress,_distributorId);  
        
        emit DoneDistributing(msg.sender, _batchNo);
        return (status);
    }
    
    
    /* get Retailer */
    
    function getRetailerData(address _batchNo) public returns (uint256 quantity,
                                                                    string memory temperature,
                                                                    string memory internalBatchNo,
                                                                    uint256 packageDateTime,
                                                                    string memory retailerName,
                                                                    string memory retailerAddress) {
        /* Call Storage Contract */
        (quantity,
         temperature,
         internalBatchNo,
         packageDateTime,
         retailerName,
         retailerAddress) =  supplyChainStorage.getRetailerData(_batchNo);  
         
         return (quantity,
                 temperature,
                 internalBatchNo,
                 packageDateTime,
                 retailerName,
                 retailerAddress);
 
    }
    
    /* perform Retailing */
    
    function updateRetailerData(address _batchNo,
                              uint256 _quantity, 
                              string memory _temperature,
                              string memory _internalBatchNo,
                              uint256 _packageDateTime,
                              string memory _retailerName,
                              string memory _retailerAddress) public payable isValidPerformer(_batchNo,'RETAILER') returns(bool) {
                                    
        /* Call Storage Contract */
        bool status = supplyChainStorage.setRetailerData(_batchNo, 
                                                        _quantity, 
                                                        _temperature, 
                                                        _internalBatchNo,
                                                        _packageDateTime,
                                                        _retailerName,
                                                        _retailerAddress);  
        
        emit DoneRetailing(msg.sender, _batchNo);
        return (status);
    }
}
