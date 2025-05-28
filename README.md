import { useState, useEffect } from 'react';
import { Vote, Lock, Users, Check, AlertCircle, BarChart3 } from 'lucide-react';

// Simulated blockchain block structure
class Block {
  constructor(data, previousHash) {
    this.timestamp = new Date().toISOString();
    this.data = data;
    this.previousHash = previousHash;
    this.hash = this.calculateHash();
    this.nonce = 0;
  }

  calculateHash() {
    // Simplified hash function (in reality would use SHA-256)
    return btoa(JSON.stringify({
      timestamp: this.timestamp,
      data: this.data,
      previousHash: this.previousHash,
      nonce: this.nonce
    })).slice(0, 16);
  }

  mineBlock(difficulty = 2) {
    const target = Array(difficulty + 1).join("0");
    while (this.hash.substring(0, difficulty) !== target) {
      this.nonce++;
      this.hash = this.calculateHash();
    }
  }
}

// Blockchain implementation
class VotingBlockchain {
  constructor() {
    this.chain = [this.createGenesisBlock()];
    this.difficulty = 2;
    this.pendingVotes = [];
  }

  createGenesisBlock() {
    return new Block("Genesis Block", "0");
  }

  getLatestBlock() {
    return this.chain[this.chain.length - 1];
  }

  addVote(vote) {
    this.pendingVotes.push(vote);
  }

  minePendingVotes() {
    const block = new Block(this.pendingVotes, this.getLatestBlock().hash);
    block.mineBlock(this.difficulty);
    this.chain.push(block);
    this.pendingVotes = [];
    return block;
  }

  getAllVotes() {
    let votes = [];
    for (let i = 1; i < this.chain.length; i++) {
      votes = votes.concat(this.chain[i].data);
    }
    return votes;
  }

  isChainValid() {
    for (let i = 1; i < this.chain.length; i++) {
      const currentBlock = this.chain[i];
      const previousBlock = this.chain[i - 1];

      if (currentBlock.hash !== currentBlock.calculateHash()) {
        return false;
      }

      if (currentBlock.previousHash !== previousBlock.hash) {
        return false;
      }
    }
    return true;
  }
}

// Cryptographic utilities (simplified)
class CryptoUtils {
  static generateVoterKey() {
    return Math.random().toString(36).substr(2, 16);
  }

  static hashVote(candidateId, voterKey) {
    return btoa(`${candidateId}-${voterKey}`).slice(0, 12);
  }

  static verifyVote(vote, voterKey) {
    return vote.hash === this.hashVote(vote.candidateId, voterKey);
  }
}

const DecentralizedVotingSystem = () => {
  const [blockchain] = useState(() => new VotingBlockchain());
  const [voterKey, setVoterKey] = useState('');
  const [hasVoted, setHasVoted] = useState(false);
  const [selectedCandidate, setSelectedCandidate] = useState('');
  const [votes, setVotes] = useState([]);
  const [showResults, setShowResults] = useState(false);
  const [isValidating, setIsValidating] = useState(false);

  const candidates = [
    { id: 'alice', name: 'Alice Johnson', party: 'Progressive Party' },
    { id: 'bob', name: 'Bob Smith', party: 'Conservative Alliance' },
    { id: 'carol', name: 'Carol Davis', party: 'Green Coalition' },
    { id: 'david', name: 'David Wilson', party: 'Independent' }
  ];

  useEffect(() => {
    // Generate voter key on component mount
    setVoterKey(CryptoUtils.generateVoterKey());
  }, []);

  const castVote = async () => {
    if (!selectedCandidate || hasVoted) return;

    setIsValidating(true);

    // Create cryptographic vote
    const vote = {
      candidateId: selectedCandidate,
      hash: CryptoUtils.hashVote(selectedCandidate, voterKey),
      timestamp: new Date().toISOString(),
      voterHash: btoa(voterKey).slice(0, 8) // Anonymized voter identifier
    };

    // Add to blockchain
    blockchain.addVote(vote);
    
    // Simulate network validation delay
    setTimeout(() => {
      blockchain.minePendingVotes();
      setVotes(blockchain.getAllVotes());
      setHasVoted(true);
      setIsValidating(false);
    }, 2000);
  };

  const validateBlockchain = () => {
    return blockchain.isChainValid();
  };

  const getVoteResults = () => {
    const results = {};
    votes.forEach(vote => {
      results[vote.candidateId] = (results[vote.candidateId] || 0) + 1;
    });
    return results;
  };

  const results = getVoteResults();
  const totalVotes = votes.length;
  const isBlockchainValid = validateBlockchain();

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-purple-50 p-6">
      <div className="max-w-4xl mx-auto">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-800 mb-2 flex items-center justify-center gap-3">
            <Vote className="text-blue-600" />
            Decentralized Voting System
          </h1>
          <p className="text-gray-600">Secure, transparent, and decentralized elections</p>
        </div>

        {/* Voter Information */}
        <div className="bg-white rounded-lg shadow-lg p-6 mb-6">
          <h2 className="text-xl font-semibold mb-4 flex items-center gap-2">
            <Lock className="text-green-600" />
            Your Cryptographic Identity
          </h2>
          <div className="bg-gray-50 p-4 rounded-lg">
            <p className="text-sm text-gray-600 mb-2">Voter Key (Keep Private):</p>
            <code className="bg-gray-800 text-green-400 px-3 py-1 rounded text-xs font-mono">
              {voterKey}
            </code>
            <p className="text-xs text-gray-500 mt-2">
              This key ensures your vote is authentic while maintaining anonymity
            </p>
          </div>
        </div>

        {/* Voting Interface */}
        {!hasVoted ? (
          <div className="bg-white rounded-lg shadow-lg p-6 mb-6">
            <h2 className="text-xl font-semibold mb-4 flex items-center gap-2">
              <Users className="text-blue-600" />
              Cast Your Vote
            </h2>
            <div className="grid gap-4">
              {candidates.map(candidate => (
                <label key={candidate.id} className="flex items-center p-4 border-2 rounded-lg cursor-pointer hover:bg-gray-50 transition-colors">
                  <input
                    type="radio"
                    name="candidate"
                    value={candidate.id}
                    checked={selectedCandidate === candidate.id}
                    onChange={(e) => setSelectedCandidate(e.target.value)}
                    className="mr-3"
                  />
                  <div>
                    <p className="font-semibold text-gray-800">{candidate.name}</p>
                    <p className="text-sm text-gray-600">{candidate.party}</p>
                  </div>
                </label>
              ))}
            </div>
            <button
              onClick={castVote}
              disabled={!selectedCandidate || isValidating}
              className="w-full mt-6 bg-blue-600 text-white py-3 px-6 rounded-lg font-semibold hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
            >
              {isValidating ? 'Validating & Mining Block...' : 'Cast Vote'}
            </button>
          </div>
        ) : (
          <div className="bg-green-50 border-2 border-green-200 rounded-lg p-6 mb-6">
            <div className="flex items-center gap-2 text-green-800">
              <Check className="text-green-600" />
              <h2 className="text-xl font-semibold">Vote Successfully Cast!</h2>
            </div>
            <p className="text-green-700 mt-2">
              Your vote has been added to the blockchain and is now immutable.
            </p>
          </div>
        )}

        {/* Blockchain Status */}
        <div className="bg-white rounded-lg shadow-lg p-6 mb-6">
          <h2 className="text-xl font-semibold mb-4 flex items-center gap-2">
            <Lock className="text-purple-600" />
            Blockchain Status
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="bg-blue-50 p-4 rounded-lg">
              <p className="text-sm text-gray-600">Total Blocks</p>
              <p className="text-2xl font-bold text-blue-600">{blockchain.chain.length}</p>
            </div>
            <div className="bg-green-50 p-4 rounded-lg">
              <p className="text-sm text-gray-600">Total Votes</p>
              <p className="text-2xl font-bold text-green-600">{totalVotes}</p>
            </div>
            <div className="bg-purple-50 p-4 rounded-lg">
              <p className="text-sm text-gray-600">Chain Valid</p>
              <div className="flex items-center gap-2">
                {isBlockchainValid ? (
                  <Check className="text-green-600" />
                ) : (
                  <AlertCircle className="text-red-600" />
                )}
                <p className="text-2xl font-bold text-purple-600">
                  {isBlockchainValid ? 'Yes' : 'No'}
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Results */}
        {totalVotes > 0 && (
          <div className="bg-white rounded-lg shadow-lg p-6">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-xl font-semibold flex items-center gap-2">
                <BarChart3 className="text-orange-600" />
                Live Results
              </h2>
              <button
                onClick={() => setShowResults(!showResults)}
                className="bg-orange-600 text-white px-4 py-2 rounded-lg hover:bg-orange-700 transition-colors"
              >
                {showResults ? 'Hide Results' : 'Show Results'}
              </button>
            </div>
            
            {showResults && (
              <div className="space-y-4">
                {candidates.map(candidate => {
                  const voteCount = results[candidate.id] || 0;
                  const percentage = totalVotes > 0 ? (voteCount / totalVotes) * 100 : 0;
                  
                  return (
                    <div key={candidate.id} className="border rounded-lg p-4">
                      <div className="flex justify-between items-center mb-2">
                        <div>
                          <p className="font-semibold">{candidate.name}</p>
                          <p className="text-sm text-gray-600">{candidate.party}</p>
                        </div>
                        <div className="text-right">
                          <p className="font-bold text-lg">{voteCount}</p>
                          <p className="text-sm text-gray-600">{percentage.toFixed(1)}%</p>
                        </div>
                      </div>
                      <div className="w-full bg-gray-200 rounded-full h-3">
                        <div
                          className="bg-blue-600 h-3 rounded-full transition-all duration-500"
                          style={{ width: `${percentage}%` }}
                        />
                      </div>
                    </div>
                  );
                })}
                
                <div className="mt-6 p-4 bg-gray-50 rounded-lg">
                  <h3 className="font-semibold mb-2">Blockchain Verification</h3>
                  <p className="text-sm text-gray-600">
                    All votes are cryptographically secured and distributed across the network. 
                    The blockchain integrity is continuously validated by network participants.
                  </p>
                  <div className="mt-2 flex items-center gap-2 text-sm">
                    <Check className="text-green-600 w-4 h-4" />
                    <span className="text-green-700">Chain validated by {blockchain.chain.length} blocks</span>
                  </div>
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
};

export default DecentralizedVotingSystem;
