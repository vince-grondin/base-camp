// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/EnumerableSet.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IWeightedVoting {
    enum Vote {
        ABSTAIN,
        AGAINST,
        FOR
    }

    error AllTokensClaimed();
    error AlreadyVoted();
    error IssueNotFound();
    error NoTokensHeld();
    error QuorumTooHigh();
    error TokensClaimed();
    error VotingClosed();

    struct IssueExternal {
        address[] voters;
        string issueDesc;
        uint votesFor;
        uint votesAgainst;
        uint votesAbstain;
        uint totalVotes;
        uint quorum;
        bool passed;
        bool closed;
    }

    /**
     * @notice Creates a new issue.
     *         Only token holders are allowed to create issues.
     *         Issues cannot be created that require a quorum greater than the current total number of tokens.
     * @param _description The description of the issue,
     * @param _quorum The number of votes are needed to close the issue.
     * @return index The index of the newly-created issue
     */
    function createIssue(
        string memory _description,
        uint _quorum
    ) external returns (uint index);

    /**
     * @notice Returns all of the data for the issue of the provided `_id`.
     * @param _id The identifier of the issue.
     * @return All of the data for the issue of the provided `_id`.
     */
    function getIssue(uint _id) external view returns (IssueExternal memory);
}

/**
 * @title A solution for the [ERC-20 Tokens Exercise](https://docs.base.org/base-camp/docs/erc-20-token/erc-20-exercise).
 * @author Roch
 */
contract WeightedVoting is ERC20, IWeightedVoting {
    using EnumerableSet for EnumerableSet.AddressSet;
    using IssueUpdates for IssueInternal;

    uint internal immutable MAX_SUPPLY = 1000000;

    uint internal immutable CLAIMABLE_AMOUNT = 100;

    IssueInternal[] internal issues;

    address internal minter;

    uint holdersCount;

    mapping(uint issueIndex => address[] issueVoters) internal voters;

    mapping(uint issueIndex => bool doesIssueExist) internal existingIssues;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {}

    struct IssueInternal {
        EnumerableSet.AddressSet voters;
        string issueDesc;
        uint votesFor;
        uint votesAgainst;
        uint votesAbstain;
        uint totalVotes;
        uint quorum;
        bool passed;
        bool closed;
    }

    /**
     * @notice Claims 100 tokens.
     * @dev Reverts with `AllTokensClaimed` if all tokens are already distributed.
     *      Reverts with `TokensClaimed` if the sender already claimed 100 tokens.
     */
    function claim() public {
        if (balanceOf(msg.sender) > 0) revert TokensClaimed();

        if (totalSupply() > MAX_SUPPLY) revert AllTokensClaimed();

        _mint(msg.sender, CLAIMABLE_AMOUNT);
        holdersCount++;
    }

    /// @inheritdoc IWeightedVoting
    function createIssue(
        string memory _description,
        uint _quorum
    ) external tokenHolder returns (uint index) {
        if (_quorum > totalSupply()) revert QuorumTooHigh();

        issues.push();
        index = issues.length - 1;
        issues[index].issueDesc = _description;
        issues[index].quorum = _quorum;

        existingIssues[index] = true;
    }

    /// @inheritdoc IWeightedVoting
    function getIssue(
        uint _id
    ) external view issueExists(_id) returns (IssueExternal memory) {
        IssueInternal storage issue = issues[_id];
        return
            IssueExternal({
                voters: voters[_id],
                issueDesc: issue.issueDesc,
                votesFor: issue.votesFor,
                votesAgainst: issue.votesAgainst,
                votesAbstain: issue.votesAbstain,
                totalVotes: issue.totalVotes,
                quorum: issue.quorum,
                passed: issue.passed,
                closed: issue.closed
            });
    }

    /**
     * @notice Submits the sender's vote for the issue identified by the supplied `_issueId`.
     * @dev Holders vote all of their tokens for, against, or abstaining from the issue.
     *      This amount is added to the appropriate member of the issue and the total number of votes collected.
     *      If this vote takes the total number of votes to or above the quorum for that vote, then:
     *      - The issue is set so that closed is true
     *      - If there are more votes for than against, set passed to true
     *      Reverts if the issue is closed, or the wallet has already voted on this issue.
     * @param _issueId The identifier of the issue.
     * @param _vote The sender's vote.
     */
    function vote(
        uint _issueId,
        Vote _vote
    ) public tokenHolder issueExists(_issueId) openedIssue(_issueId) {
        for (uint i = 0; i < voters[_issueId].length; i++) {
            if (voters[_issueId][i] == msg.sender) revert AlreadyVoted();
        }

        IssueInternal storage issue = issues[_issueId];

        issue.increaseVotesCounts(_vote);

        voters[_issueId].push(msg.sender);

        issue.updateState();
    }

    /**
     * @dev Verifies the sender is a token holder. Reverts with a `NoTokensHeld` error if not.
     */
    modifier tokenHolder() {
        if (balanceOf(msg.sender) == 0) revert NoTokensHeld();
        _;
    }

    /**
     * @dev Verifies that the issue identified by `_id` exists. Reverts with a `IssueNotFound` error if not.
     * @param _id The identifier of the issue.
     */
    modifier issueExists(uint _id) {
        if (existingIssues[_id] == false) revert IssueNotFound();
        _;
    }

    /**
     * @dev Verifies that the issued identified by `_id` is not closed. Reverts with a `VotingClosed` error if it is.
     * @param _id The identifier of the issue.
     */
    modifier openedIssue(uint _id) {
        if (issues[_id].closed) revert VotingClosed();
        _;
    }
}

library IssueUpdates {
    /**
     * @dev Mutates the fields that need to be modified when a new vote is submitted.
     * @param _issue The issue being voted on.
     * @param _vote The new vote for this issue.
     */
    function increaseVotesCounts(
        WeightedVoting.IssueInternal storage _issue,
        IWeightedVoting.Vote _vote
    ) internal {
        if (_vote == IWeightedVoting.Vote.ABSTAIN) _issue.votesAbstain++;
        else if (_vote == IWeightedVoting.Vote.AGAINST) _issue.votesAgainst++;
        else if (_vote == IWeightedVoting.Vote.FOR) _issue.votesFor++;
        _issue.totalVotes++;
    }

    /**
     * @dev Updates the `closed` and `passed` state fields of the supplied `_issue` based on the values of other
     *      attributes of the issue (eg. `totalVotes` and `quorum`).
     * @param _issue The issue for which the `closed` and `passed` state fields need to be synchronized based on the
     *        values of other attributes of the issue (eg. `totalVotes` and `quorum`).
     */
    function updateState(WeightedVoting.IssueInternal storage _issue) internal {
        _issue.closed = _issue.totalVotes >= _issue.quorum;

        if (_issue.closed) {
            _issue.passed = _issue.votesFor > _issue.votesAgainst;
        }
    }
}
