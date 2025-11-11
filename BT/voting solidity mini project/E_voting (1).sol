// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
 * Title: E-Voting Smart Contract
 * Aim: To create a secure and transparent voting system using Solidity.
 * Features:
 * - Owner can add candidates and manage election lifecycle.
 * - Each voter can vote only once.
 * - Publicly viewable candidates and results.
 * - Reusable for new elections.
 */

contract EVoting {
    address public owner;
    bool public electionActive;
    uint256 public candidateCount;

    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }

    struct Voter {
        bool voted;
        uint256 votedFor; // candidate id
    }

    mapping(uint256 => Candidate) private candidates;
    mapping(address => Voter) private voters;

    // Events for logging
    event CandidateAdded(uint256 indexed id, string name);
    event ElectionStarted();
    event ElectionEnded();
    event Voted(address indexed voter, uint256 indexed candidateId);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier whenElectionActive() {
        require(electionActive, "Election is not active");
        _;
    }

    modifier whenElectionNotActive() {
        require(!electionActive, "Election is already active");
        _;
    }

    // Constructor
    constructor() {
        owner = msg.sender;
    }

    // Function to add a candidate (Only owner, before election starts)
    function addCandidate(string calldata _name)
        external
        onlyOwner
        whenElectionNotActive
    {
        require(bytes(_name).length > 0, "Candidate name required");

        // Prevent duplicate candidate names
        for (uint256 i = 1; i <= candidateCount; i++) {
            require(
                keccak256(bytes(candidates[i].name)) != keccak256(bytes(_name)),
                "Candidate already exists"
            );
        }

        candidateCount++;
        candidates[candidateCount] = Candidate(candidateCount, _name, 0);
        emit CandidateAdded(candidateCount, _name);
    }

    // Start the election
    function startElection() external onlyOwner whenElectionNotActive {
        require(candidateCount > 0, "No candidates added");
        electionActive = true;
        emit ElectionStarted();
    }

    // End the election
    function endElection() external onlyOwner whenElectionActive {
        electionActive = false;
        emit ElectionEnded();
    }

    // Vote for a candidate
    function vote(uint256 _candidateId) external whenElectionActive {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You have already voted");

        sender.voted = true;
        sender.votedFor = _candidateId;
        candidates[_candidateId].voteCount++;

        emit Voted(msg.sender, _candidateId);
    }

    // Get single candidate details
    function getCandidate(uint256 _candidateId)
        external
        view
        returns (uint256 id, string memory name, uint256 voteCount)
    {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        Candidate storage c = candidates[_candidateId];
        return (c.id, c.name, c.voteCount);
    }

    // Get all candidates
    function getAllCandidates() external view returns (Candidate[] memory) {
        Candidate[] memory all = new Candidate[](candidateCount);
        for (uint256 i = 1; i <= candidateCount; i++) {
            all[i - 1] = candidates[i];
        }
        return all;
    }

    // Get election status
    function getElectionStatus() external view returns (string memory) {
        return electionActive ? "Election is active" : "Election is not active";
    }

    // Get total candidates
    function getCandidatesCount() external view returns (uint256) {
        return candidateCount;
    }

    // Check if a voter has voted and for whom
    function hasVoted(address _voter) external view returns (bool voted, uint256 votedFor) {
        Voter storage v = voters[_voter];
        return (v.voted, v.votedFor);
    }

    // Get total votes cast
    function getTotalVotes() external view returns (uint256 totalVotes) {
        for (uint256 i = 1; i <= candidateCount; i++) {
            totalVotes += candidates[i].voteCount;
        }
    }

    // Transfer ownership
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        require(_newOwner != owner, "Already the owner");
        address oldOwner = owner;
        owner = _newOwner;
        emit OwnershipTransferred(oldOwner, _newOwner);
    }

    // Reset election for reuse
    function resetElection() external onlyOwner whenElectionNotActive {
        for (uint256 i = 1; i <= candidateCount; i++) {
            delete candidates[i];
        }
        candidateCount = 0;
        electionActive = false;
    }
}
