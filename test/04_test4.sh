#!/bin/sh
# --------------------------------------------------------------------
# Testing SikobarPresale Contracts
#
# 4. After presale period when funding goal reached
# 4.1 Participant cannot contribute
# 4.2 Participant cannot withdraw
# 4.3 Owner cannot clawback
# 4.4 Owner can withdraw partial amounts
# 4.5 Owner can withdraw full amount
#
# (c) BokkyPooBah & Sikoba 2017. The MIT licence.
# --------------------------------------------------------------------

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`
SIKOBAPRESALESOL=`grep ^SIKOBAPRESALESOL= settings.txt | sed "s/^.*=//"`
SIKOBAPRESALETEMPSOL=`grep ^SIKOBAPRESALETEMPSOL= settings.txt | sed "s/^.*=//"`
INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST4OUTPUT=`grep ^TEST4OUTPUT= settings.txt | sed "s/^.*=//"`
TEST4RESULTS=`grep ^TEST4RESULTS= settings.txt | sed "s/^.*=//"`

MINIMUM_PARTICIPATION_AMOUNT=`grep ^MINIMUM_PARTICIPATION_AMOUNT= settings.txt | sed "s/^.*=//"`
MAXIMUM_PARTICIPATION_AMOUNT=`grep ^MAXIMUM_PARTICIPATION_AMOUNT= settings.txt | sed "s/^.*=//"`
PRESALE_MINIMUM_FUNDING=`grep ^PRESALE_MINIMUM_FUNDING_TEST4= settings.txt | sed "s/^.*=//"`
PRESALE_MAXIMUM_FUNDING=`grep ^PRESALE_MAXIMUM_FUNDING= settings.txt | sed "s/^.*=//"`
TOTAL_PREALLOCATION=`grep ^TOTAL_PREALLOCATION= settings.txt | sed "s/^.*=//"`
TOTAL_PREALLOCATION_AMOUNT=`grep ^TOTAL_PREALLOCATION_AMOUNT= settings.txt | sed "s/^.*=//"`
TOTAL_PREALLOCATION_UNIT=`grep ^TOTAL_PREALLOCATION_UNIT= settings.txt | sed "s/^.*=//"`
PREALLOCATION_ACCOUNT_1=`grep ^PREALLOCATION_ACCOUNT_1= settings.txt | sed "s/^.*=//"`
PREALLOCATION_AMOUNT_1=`grep ^PREALLOCATION_AMOUNT_1= settings.txt | sed "s/^.*=//"`
PREALLOCATION_ACCOUNT_2=`grep ^PREALLOCATION_ACCOUNT_2= settings.txt | sed "s/^.*=//"`
PREALLOCATION_AMOUNT_2=`grep ^PREALLOCATION_AMOUNT_2= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`
CURRENTTIMEM10M=`echo "$CURRENTTIME-60*10" | bc`
CURRENTTIMEM10MS=`date -r $CURRENTTIMEM10M -u`
CURRENTTIMEM5M=`echo "$CURRENTTIME-60*5" | bc`
CURRENTTIMEM5MS=`date -r $CURRENTTIMEM5M -u`
CURRENTTIMEP1M=`echo "$CURRENTTIME+60" | bc`
CURRENTTIMEP1MS=`date -r $CURRENTTIMEP1M -u`
CURRENTTIMEP5M=`echo "$CURRENTTIME+60*5" | bc`
CURRENTTIMEP5MS=`date -r $CURRENTTIMEP5M -u`
CURRENTTIMEP10M=`echo "$CURRENTTIME+60*10" | bc`
CURRENTTIMEP10MS=`date -r $CURRENTTIMEP10M -u`

printf "GETHATTACHPOINT              = '$GETHATTACHPOINT'\n"
printf "PASSWORD                     = '$PASSWORD'\n"
printf "SIKOBAPRESALESOL             = '$SIKOBAPRESALESOL'\n"
printf "SIKOBAPRESALETEMPSOL         = '$SIKOBAPRESALETEMPSOL'\n"
printf "INCLUDEJS                    = '$INCLUDEJS'\n"
printf "TEST4OUTPUT                  = '$TEST4OUTPUT'\n"
printf "TEST4RESULTS                 = '$TEST4RESULTS'\n"
printf "MINIMUM_PARTICIPATION_AMOUNT = '$MINIMUM_PARTICIPATION_AMOUNT'\n"
printf "MAXIMUM_PARTICIPATION_AMOUNT = '$MAXIMUM_PARTICIPATION_AMOUNT'\n"
printf "PRESALE_MINIMUM_FUNDING      = '$PRESALE_MINIMUM_FUNDING'\n"
printf "PRESALE_MAXIMUM_FUNDING      = '$PRESALE_MAXIMUM_FUNDING'\n"
printf "TOTAL_PREALLOCATION          = '$TOTAL_PREALLOCATION'\n"
printf "TOTAL_PREALLOCATION_AMOUNT   = '$TOTAL_PREALLOCATION_AMOUNT'\n"
printf "TOTAL_PREALLOCATION_UNIT     = '$TOTAL_PREALLOCATION_UNIT'\n"
printf "PREALLOCATION_ACCOUNT_1      = '$PREALLOCATION_ACCOUNT_1'\n"
printf "PREALLOCATION_AMOUNT_1       = '$PREALLOCATION_AMOUNT_1'\n"
printf "PREALLOCATION_ACCOUNT_2      = '$PREALLOCATION_ACCOUNT_2'\n"
printf "PREALLOCATION_AMOUNT_2       = '$PREALLOCATION_AMOUNT_2'\n"
printf "CURRENTTIME                  = '$CURRENTTIME' '$CURRENTTIMES'\n"
printf "CURRENTTIMEM10M              = '$CURRENTTIMEM10M' '$CURRENTTIMEM10MS'\n"
printf "CURRENTTIMEM5M               = '$CURRENTTIMEM5M' '$CURRENTTIMEM5MS'\n"
printf "CURRENTTIMEP1M               = '$CURRENTTIMEP1M' '$CURRENTTIMEP1MS'\n"
printf "CURRENTTIMEP5M               = '$CURRENTTIMEP5M' '$CURRENTTIMEP5MS'\n"
printf "CURRENTTIMEP10M              = '$CURRENTTIMEP10M' '$CURRENTTIMEP10MS'\n"

# --- Make copy of SOL file and strip out comments ---
`cp $SIKOBAPRESALESOL $SIKOBAPRESALETEMPSOL`
`perl -pi -e "s/^\/\*.*$//; s/^ \*.*$//; " $SIKOBAPRESALETEMPSOL`

# --- Modify dates ---
# PRESALE_START_DATE = +1m
`perl -pi -e "s/PRESALE_START_DATE = 1491393600;/PRESALE_START_DATE = $CURRENTTIMEM10M; \/\/ $CURRENTTIMEM10MS/" $SIKOBAPRESALETEMPSOL`
# PRESALE_END_DATE = +5m
`perl -pi -e "s/PRESALE_END_DATE = PRESALE_START_DATE \+ 2 weeks;/PRESALE_END_DATE = $CURRENTTIMEM5M; \/\/ $CURRENTTIMEM5MS/" $SIKOBAPRESALETEMPSOL`
# OWNER_CLAWBACK_DATE = +10m
`perl -pi -e "s/OWNER_CLAWBACK_DATE = 1514808000;/OWNER_CLAWBACK_DATE = $CURRENTTIMEP10M; \/\/ $CURRENTTIMEP10MS/" $SIKOBAPRESALETEMPSOL`

# --- Modify amounts ---
`perl -pi -e "s/MINIMUM_PARTICIPATION_AMOUNT =   5 ether;/MINIMUM_PARTICIPATION_AMOUNT = $MINIMUM_PARTICIPATION_AMOUNT;/" $SIKOBAPRESALETEMPSOL`
`perl -pi -e "s/MAXIMUM_PARTICIPATION_AMOUNT = 250 ether;/MAXIMUM_PARTICIPATION_AMOUNT = $MAXIMUM_PARTICIPATION_AMOUNT;/" $SIKOBAPRESALETEMPSOL`
`perl -pi -e "s/PRESALE_MINIMUM_FUNDING =  9000 ether;/PRESALE_MINIMUM_FUNDING = $PRESALE_MINIMUM_FUNDING;/" $SIKOBAPRESALETEMPSOL`
`perl -pi -e "s/PRESALE_MAXIMUM_FUNDING = 18000 ether;/PRESALE_MAXIMUM_FUNDING = $PRESALE_MAXIMUM_FUNDING;/" $SIKOBAPRESALETEMPSOL`
`perl -pi -e "s/TOTAL_PREALLOCATION = 15 ether;/TOTAL_PREALLOCATION = $TOTAL_PREALLOCATION;/" $SIKOBAPRESALETEMPSOL`
`perl -pi -e "s/addBalance\(0xdeadbeef, 10 wei\);/addBalance($PREALLOCATION_ACCOUNT_1, $PREALLOCATION_AMOUNT_1);/" $SIKOBAPRESALETEMPSOL`
`perl -pi -e "s/addBalance\(0xcafebabe, 5 wei\);/addBalance($PREALLOCATION_ACCOUNT_2, $PREALLOCATION_AMOUNT_2);/" $SIKOBAPRESALETEMPSOL`

# --- Check differences ---
TEST=`diff $SIKOBAPRESALESOL $SIKOBAPRESALETEMPSOL`
echo "--- Differences ---"
echo "$TEST"

FLATTENEDSOL=`./stripCrLf $SIKOBAPRESALETEMPSOL | tr -s ' '`
printf "var sikobaPresaleSource = \"$FLATTENEDSOL\"" > $INCLUDEJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee $TEST4OUTPUT
loadScript("functions.js");
unlockAccounts("$PASSWORD");
printBalances();

// Load source code
loadScript("$INCLUDEJS");
console.log("sikobaPresaleSource=" + sikobaPresaleSource);
// Compile source code
var sikobaPresaleCompiled = web3.eth.compile.solidity(sikobaPresaleSource);
console.log("----------v sikobaPresaleCompiled v----------");
sikobaPresaleCompiled;
console.log("----------^ sikobaPresaleCompiled ^----------");
console.log("DATA: sikobaPresaleABI=" + JSON.stringify(sikobaPresaleCompiled["<stdin>:SikobaPresale"].info.abiDefinition));

// Test 4 contract setup
var sikobaPresaleAddress = null;
var sikobaPresaleTx = null;
var sikobaPresaleContract = web3.eth.contract(sikobaPresaleCompiled["<stdin>:SikobaPresale"].info.abiDefinition);
var sikobaPresale = sikobaPresaleContract.new({from: ownerAccount, data: sikobaPresaleCompiled["<stdin>:SikobaPresale"].code, value: web3.toWei("$TOTAL_PREALLOCATION_AMOUNT", "$TOTAL_PREALLOCATION_UNIT"), gas: 800000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        sikobaPresaleTx = contract.transactionHash;
        console.log("sikobaPresaleTx=" + sikobaPresaleTx);
      } else {
        sikobaPresaleAddress = contract.address;
        addAccount(sikobaPresaleAddress, "SikobaPresaleContract #1");
        console.log("DATA: sikobaPresaleAddress=" + sikobaPresaleAddress);
        printTxData("sikobaPresaleAddress=" + sikobaPresaleAddress, sikobaPresaleTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
var gas = eth.getTransaction(sikobaPresaleTx).gas;
var gasUsed = eth.getTransactionReceipt(sikobaPresaleTx).gasUsed;
if (sikobaPresaleAddress == null || gas == gasUsed) {
  console.log("RESULT: FAIL Test 4 Contract Setup");
} else {
  console.log("RESULT: PASS Test 4 Contract Setup");
}

// 4. After presale period when funding goal reached
// Test 4.1 Participants cannot contribute
var sendContribution41TxId = eth.sendTransaction({from: presaleParticipant1Account, to: sikobaPresaleAddress, value: web3.toWei(100, "ether"), gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("sendContribution41TxId", sendContribution41TxId);
printBalances();
gas = eth.getTransaction(sendContribution41TxId).gas;
gasUsed = eth.getTransactionReceipt(sendContribution41TxId).gasUsed;
if (gas == gasUsed) {
  console.log("RESULT: PASS Test 4.1 Participants cannot contribute");
} else {
  console.log("RESULT: FAIL Test 4.1 Participants cannot contribute");
}

// 4.2 Participant cannot withdraw
var balance = sikobaPresale.balanceOf(preallocationParticipant1Account);
console.log("RESULT: preallocationParticipant1Account balance=" + web3.fromWei(balance, "ether"));
var participantWithdraw42TxId = sikobaPresale.participantWithdrawIfMinimumFundingNotReached(web3.toWei(100, "ether"), {from: preallocationParticipant1Account, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("participantWithdraw42TxId", participantWithdraw42TxId);
printBalances();
gas = eth.getTransaction(participantWithdraw42TxId).gas;
gasUsed = eth.getTransactionReceipt(participantWithdraw42TxId).gasUsed;
if (gas == gasUsed) {
  console.log("RESULT: PASS Test 4.2 Participant cannot withdraw");
} else {
  console.log("RESULT: FAIL Test 4.2 Participant cannot withdraw");
}

// Test 4.3 Owner cannot clawback
var clawback43TxId = sikobaPresale.ownerClawback({from: ownerAccount, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("clawback43TxId", clawback43TxId);
printBalances();
gas = eth.getTransaction(clawback43TxId).gas;
gasUsed = eth.getTransactionReceipt(clawback43TxId).gasUsed;
if (gas == gasUsed) {
  console.log("RESULT: PASS Test 4.3 Owner cannot clawback");
} else {
  console.log("RESULT: FAIL Test 4.3 Owner cannot clawback");
}

// Test 4.4 Owner can withdraw partial amounts
balance = eth.getBalance(sikobaPresaleAddress);
console.log("RESULT: sikobaPresaleAddress balance=" + web3.fromWei(balance, "ether"));
console.log("RESULT: Test 4.4 Owner can withdraw partial amounts - withdrawing 100 ETH");
var ownerWithdrawPartial44TxId = sikobaPresale.ownerWithdraw(web3.toWei(100, "ether"), {from: ownerAccount, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("ownerWithdrawPartial44TxId", ownerWithdrawPartial44TxId);
printBalances();
gas = eth.getTransaction(ownerWithdrawPartial44TxId).gas;
gasUsed = eth.getTransactionReceipt(ownerWithdrawPartial44TxId).gasUsed;
if (gas == gasUsed) {
  console.log("RESULT: FAIL Test 4.4 Owner can withdraw partial amounts");
} else {
  console.log("RESULT: PASS Test 4.4 Owner can withdraw partial amounts");
}

// Test 4.5 Owner can withdraw full amount
balance = eth.getBalance(sikobaPresaleAddress);
console.log("RESULT: sikobaPresaleAddress balance=" + web3.fromWei(balance, "ether"));
console.log("RESULT: Test 4.5 Owner can withdraw full amount - withdrawing remainder");
var ownerWithdrawRemainder45TxId = sikobaPresale.ownerWithdraw(balance, {from: ownerAccount, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("ownerWithdrawRemainder45TxId", ownerWithdrawRemainder45TxId);
printBalances();
gas = eth.getTransaction(ownerWithdrawRemainder45TxId).gas;
gasUsed = eth.getTransactionReceipt(ownerWithdrawRemainder45TxId).gasUsed;
if (gas == gasUsed) {
  console.log("RESULT: FAIL Test 4.5 Owner can withdraw full amount");
} else {
  console.log("RESULT: PASS Test 4.5 Owner can withdraw full amount");
}

EOF
grep "RESULT: " $TEST4OUTPUT | sed "s/RESULT: //" > $TEST4RESULTS
cat $TEST4RESULTS