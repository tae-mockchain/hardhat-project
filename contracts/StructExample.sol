// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract StructExample {
    // User profile struct
    struct User {
        uint256 id;
        string name;
        string email;
        uint256 registrationDate;
        bool isActive;
        address wallet;
    }

    // Product struct
    struct Product {
        uint256 id;
        string name;
        string description;
        uint256 price; // in wei
        uint256 stock;
        bool isAvailable;
        address owner;
    }

    // Order struct
    struct Order {
        uint256 id;
        uint256 userId;
        uint256 productId;
        uint256 quantity;
        uint256 totalPrice;
        OrderStatus status;
        uint256 orderDate;
        uint256 deliveryDate;
    }

    // Order status enum
    enum OrderStatus {
        Pending,
        Confirmed,
        Shipped,
        Delivered,
        Cancelled
    }

    // Address struct for shipping
    struct Address {
        string street;
        string city;
        string state;
        string zipCode;
        string country;
    }

    // Complex struct with nested structs
    struct UserProfile {
        User user;
        Address shippingAddress;
        uint256 totalOrders;
        uint256 loyaltyPoints;
    }

    // Main data struct containing all mappings
    struct Data {
        mapping(uint256 => User) users;
        mapping(uint256 => Product) products;
        mapping(uint256 => Order) orders;
        uint256 totalUsers;
        uint256 totalProducts;
        uint256 totalOrders;
    }

    // Single state variable containing all data
    Data public stored;

    // Events
    event UserCreated(uint256 indexed userId, string name, address wallet);
    event ProductAdded(uint256 indexed productId, string name, uint256 price);
    event OrderPlaced(uint256 indexed orderId, uint256 userId, uint256 productId);
    event OrderStatusUpdated(uint256 indexed orderId, OrderStatus newStatus);

    // User management functions
    function createUser(
        string memory _name,
        string memory _email,
        address _wallet
    ) public returns (uint256) {
        stored.totalUsers++;
        stored.users[stored.totalUsers] = User({
            id: stored.totalUsers,
            name: _name,
            email: _email,
            registrationDate: block.timestamp,
            isActive: true,
            wallet: _wallet
        });

        emit UserCreated(stored.totalUsers, _name, _wallet);
        return stored.totalUsers;
    }

    function createUserProfile(
        uint256 _userId,
        string memory /* _street */,
        string memory /* _city */,
        string memory /* _state */,
        string memory /* _zipCode */,
        string memory /* _country */
    ) public view {
        require(stored.users[_userId].id != 0, "User does not exist");
        
        // Note: userProfiles mapping was removed from struct, so this function is simplified
        // You may want to add userProfiles back as a separate mapping if needed
    }

    // Product management functions
    function addProduct(
        string memory _name,
        string memory _description,
        uint256 _price,
        uint256 _stock,
        address _owner
    ) public returns (uint256) {
        stored.totalProducts++;
        stored.products[stored.totalProducts] = Product({
            id: stored.totalProducts,
            name: _name,
            description: _description,
            price: _price,
            stock: _stock,
            isAvailable: _stock > 0,
            owner: _owner
        });

        emit ProductAdded(stored.totalProducts, _name, _price);
        return stored.totalProducts;
    }

    function updateProductStock(uint256 _productId, uint256 _newStock) public {
        require(stored.products[_productId].id != 0, "Product does not exist");
        stored.products[_productId].stock = _newStock;
        stored.products[_productId].isAvailable = _newStock > 0;
    }

    // Order management functions
    function placeOrder(
        uint256 _userId,
        uint256 _productId,
        uint256 _quantity
    ) public returns (uint256) {
        require(stored.users[_userId].id != 0, "User does not exist");
        require(stored.products[_productId].id != 0, "Product does not exist");
        require(stored.products[_productId].stock >= _quantity, "Insufficient stock");
        require(stored.products[_productId].isAvailable, "Product not available");

        stored.totalOrders++;
        uint256 totalPrice = stored.products[_productId].price * _quantity;

        stored.orders[stored.totalOrders] = Order({
            id: stored.totalOrders,
            userId: _userId,
            productId: _productId,
            quantity: _quantity,
            totalPrice: totalPrice,
            status: OrderStatus.Pending,
            orderDate: block.timestamp,
            deliveryDate: 0
        });

        // Update stock
        stored.products[_productId].stock -= _quantity;
        if (stored.products[_productId].stock == 0) {
            stored.products[_productId].isAvailable = false;
        }

        // Note: userProfiles functionality removed since it's not in the struct anymore

        emit OrderPlaced(stored.totalOrders, _userId, _productId);
        return stored.totalOrders;
    }

    function updateOrderStatus(uint256 _orderId, OrderStatus _newStatus) public {
        require(stored.orders[_orderId].id != 0, "Order does not exist");
        stored.orders[_orderId].status = _newStatus;
        
        if (_newStatus == OrderStatus.Delivered) {
            stored.orders[_orderId].deliveryDate = block.timestamp;
        }

        emit OrderStatusUpdated(_orderId, _newStatus);
    }

    // View functions
    function getUser(uint256 _userId) public view returns (User memory) {
        return stored.users[_userId];
    }

    function getProduct(uint256 _productId) public view returns (Product memory) {
        return stored.products[_productId];
    }

    function getOrder(uint256 _orderId) public view returns (Order memory) {
        return stored.orders[_orderId];
    }

    // getUserProfile function removed since userProfiles is not in the struct anymore

    function getOrderStatus(uint256 _orderId) public view returns (OrderStatus) {
        return stored.orders[_orderId].status;
    }

    // Utility functions
    function isUserActive(uint256 _userId) public view returns (bool) {
        return stored.users[_userId].isActive;
    }

    function getProductAvailability(uint256 _productId) public view returns (bool) {
        return stored.products[_productId].isAvailable && stored.products[_productId].stock > 0;
    }

    // getTotalOrdersByUser and getLoyaltyPoints functions removed since userProfiles is not in the struct anymore
}
