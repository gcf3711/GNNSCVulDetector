
 

pragma solidity ^0.5.16;

interface Unitroller {
    function admin() external view returns (address);
    function _acceptImplementation() external returns (uint);
}

 
contract Comptroller {
     
    address internal constant fuseAdmin = 0xa731585ab05fC9f83555cf9Bff8F58ee94e18F85;

     
    address internal admin;

     
    address internal pendingAdmin;

     
    bool internal fuseAdminHasRights;

     
    bool internal adminHasRights;

     
    event AdminRightsToggled(bool hasRights);

     
    function _toggleAdminRights(bool hasRights) external returns (uint) {
         
        require(msg.sender == fuseAdmin, "Sender not Fuse admin.");

         
        if (adminHasRights == hasRights) return 0;

         
        adminHasRights = hasRights;

         
        emit AdminRightsToggled(hasRights);

         
        return 0;
    }

     
    function _become(Unitroller unitroller) public {
        require(msg.sender == unitroller.admin(), "only unitroller admin can change brains");
        require(unitroller._acceptImplementation() == 0, "change not authorized");
    }
}