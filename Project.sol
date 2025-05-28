// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleVotingSystem {
    // Structure to store candidate information
    struct Candidate {
        string name;
        uint256 voteCount;
    }
    
    // Array to store all candidates
    Candidate[] public candidates;
    
    // Track if an address has voted
    mapping(address => bool) public hasVoted;
    
    // Contract owner (who can add candidates)
    address public owner;
    
    // Events
    event CandidateAdded(string name);
    event VoteCasted(address voter, uint256 candidateIndex);
    
    // Constructor - sets the contract deployer as owner
    constructor() {
        owner = msg.sender;
    }
    
    // Modifier to restrict functions to owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    // Core Function 1: Add a new candidate (only owner can do this)
    function addCandidate(string memory _name) public onlyOwner {
        candidates.push(Candidate({
            name: _name,
            voteCount: 0
        }));
        
        emit CandidateAdded(_name);
    }
    
    // Core Function 2: Vote for a candidate
    function vote(uint256 _candidateIndex) public {
        // Check if voter has already voted
        require(!hasVoted[msg.sender], "You have already voted");
        
        // Check if candidate index is valid
        require(_candidateIndex < candidates.length, "Invalid candidate");
        
        // Mark that this address has voted
        hasVoted[msg.sender] = true;
        
        // Increase vote count for the candidate
        candidates[_candidateIndex].voteCount++;
        
        emit VoteCasted(msg.sender, _candidateIndex);
    }
    
    // Core Function 3: Get voting results
    function getResults() public view returns (string[] memory names, uint256[] memory voteCounts) {
        names = new string[](candidates.length);
        voteCounts = new uint256[](candidates.length);
        
        for (uint256 i = 0; i < candidates.length; i++) {
            names[i] = candidates[i].name;
            voteCounts[i] = candidates[i].voteCount;
        }
        
        return (names, voteCounts);
    }
    
    // Helper function: Get total number of candidates
    function getTotalCandidates() public view returns (uint256) {
        return candidates.length;
    }
    
    // Helper function: Get candidate details by index
    function getCandidate(uint256 _index) public view returns (string memory name, uint256 voteCount) {
        require(_index < candidates.length, "Invalid candidate index");
        return (candidates[_index].name, candidates[_index].voteCount);
    }
    
    // Helper function: Check if an address has voted
    function checkIfVoted(address _voter) public view returns (bool) {
        return hasVoted[_voter];
    }
}
