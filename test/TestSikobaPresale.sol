pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SikobaPresale.sol";

contract TestSikobaPresale {

  function testInitialBalanceUsingDeployedContract() {
    SikobaPresale presale = SikobaPresale(DeployedAddresses.SikobaPresale());

    uint expected = 10;

    Assert.equal(presale.balanceOf(0xdeadbeef), expected, "Deabbeef should have 10 Ether initially");
  }

  function testInitialBalanceWithNewSikobaPresale() {
    SikobaPresale presale = new SikobaPresale();

    uint expected = 10;

    Assert.equal(presale.balanceOf(0xdeadbeef), expected, "Deabbeef should have 10 Ether initially");
  }

}
