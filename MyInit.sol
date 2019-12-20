pragma solidity >=0.4.24 <0.6.0;
contract Store {
    address owner;
    
    struct Item {
        address owner;
        string name;
        uint price;
        uint buy_time_stamp;
        address buyer;
        bool cashback;
    }
    
    Item[] items;
    
    constructor() public {
        owner = msg.sender;// owner of the store 
    }
    
    function withdraw () public returns (uint amount){
        
        uint total = 0;
        for (uint i=0; i<items.length;++i) {
            if (items[i].owner == msg.sender && items[i].buyer != 0 && items[i].cashback == false) {
                if (now - items[i].buy_time_stamp > 60 days) {
                    total += items[i].price;
                    items[i].cashback = true;
                }
            }
        }
        
        msg.sender.transfer (total);
        return total;
    }
    
    function upload (string product, uint _price) public {
        items.push (Item ({
            owner : msg.sender,
            name : product,
            price : _price,
            buy_time_stamp : 0,
            buyer : 0,
            cashback : false
        }));
    }
    
    function buy (uint id) public payable{ // to be simple, buy product using id
        require(id<items.length);
        Item storage item = items[id];
        require (item.buy_time_stamp != 0, "This product has been already bought");
        uint paid = msg.value; 
        require (paid>item.price, "You cannot afford this");
        owner.transfer (paid);
        item.buyer = msg.sender; // who buy this product
    }
    
    function refund (uint id) public{
        Item storage item = items[id];
        if (item.buy_time_stamp != 0) {
            require (now - item.buy_time_stamp <= 60 days, "You cannot refund");
            item.buyer.transfer (item.price); // refunding
            item.buy_time_stamp = 0;
            item.buyer = 0;
        }
    }
}
