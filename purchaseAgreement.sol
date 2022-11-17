// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract PurchaseAgreement {
    uint public value;
    address payable public seller;
    address payable public buyer;
    enum State {Created, Locked, Released, Inactive}
    State public state;

    constructor() payable {
        seller = payable(msg.sender);
        value = msg.value / 2;
        state = State.Created;
    }

    /// The function cannot be called at the current state.
    error InvalidState();
    /// Only buyer can call this option
    error OnlyBuyer();

    /// Only seller can call this option
    error OnlySeller();

    modifier inState(State _state) {
        if (state != _state) revert InvalidState();
        _;
    }
    modifier onlyBuyer() {
        if (msg.sender != buyer) revert OnlyBuyer();
        _;
    }
    modifier onlySeller() {
        if (msg.sender != seller) revert OnlySeller();
        _;
    }

    function buyerConfirmsPurchase() external inState(State.Created) payable {
        require(msg.value == (2*value), "Please send in 2x the purchase amount");
        buyer = payable(msg.sender);
        state = State.Locked;
    }

    function buyerConfirmsReceived() external onlyBuyer inState(State.Locked) {
        state = State.Released;
        buyer.transfer(value);
    }

    function payBackSeller() external onlySeller inState(State.Released) {
        state = State.Inactive;
        seller.transfer(3*value);
    }

    function sellerAbort() external onlySeller inState(State.Created) {
        state = State.Inactive;
        seller.transfer(address(this).balance);
    }
}
