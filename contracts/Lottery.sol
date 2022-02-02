pragma solidity ^0.4.17 ;

contract factory {
    address[] public deployedCampaigns;

    function createCampign (uint minimum) public {
        address newCampaign = new Campaign(minimum, msg.sender) ; // create new contract that deploys to network 
        deployedCampaigns.push(newCampaign); 
    }

    function getDeployedCampaigns () public view returns (address[]) {
        return deployedCampaigns; 
    }


}

contract Campaign{
    
   struct Request{
        string description;
        uint value; 
        address recipient; 
        bool complete;
        uint approvalCount;
        mapping (address=>bool) approvals ; 
    }

    address public manager; 
    uint public minContribution; 
    mapping (address=>bool) public approvers;
    Request[] public requests; 
    uint public approversCount; 

    modifier restricted(){
        require (msg.sender == manager);
        _;
    }

    function Campaign (uint minimum, address creatore) public {
        manager = creatore; 
        minContribution = minimum; 
    }

    function contribute() public payable {
        require( msg.value > minContribution );
        
        approvers[msg.sender] = true; 
        approversCount++; 
    }


    function createRequest (string description, uint value, address recipient) public restricted {
        Request memory newRequest = Request ({
            description : description , 
            value : value , 
            recipient : recipient , 
            complete : false, 
            approvalCount : 0 
        });
    requests.push(newRequest) ; 
    }

    function approveRequest (uint index) public {
        Request storage request = requests[index] ; 
        require (approvers[msg.sender]) ; // make sure this address donated money 
        require (! request.approvals[msg.sender]) ; // make sure this address did not vote before 

        request.approvals[msg.sender] = true ; 
        request.approvalCount++; 
    }

    function finalizeRequest (uint index) public restricted{
        Request storage request = requests [index]; 
        require (request.approvalCount > (approversCount / 2));
        require (! request.complete) ; 
        
        request.recipient.transfer(request.value); 
        request.complete = true ;
    }
}