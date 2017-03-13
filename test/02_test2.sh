#!/bin/sh
# --------------------------------------------------------------------
# Testing SikobarPresale Contracts
#
# Test 2
# 2. During the presale period
# 2.1 Participant cannot contribute below minimum amount
# 2.2 Participant cannot contribute above maximum amount
# 2.3 Participant can contribute in correct range
# 2.4 Participant cannot contribute once funding max reached
# 2.5 Owner cannot withdraw
# 2.6 Owner cannot clawback
# 2.7 Participant cannot withdraw
#
# (c) BokkyPooBah & Sikoba 2017. The MIT licence.
# --------------------------------------------------------------------

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`
SIKOBAPRESALESOL=`grep ^SIKOBAPRESALESOL= settings.txt | sed "s/^.*=//"`
SIKOBAPRESALETEMPSOL=`grep ^SIKOBAPRESALETEMPSOL= settings.txt | sed "s/^.*=//"`
INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST2OUTPUT=`grep ^TEST2OUTPUT= settings.txt | sed "s/^.*=//"`
TEST2RESULTS=`grep ^TEST2RESULTS= settings.txt | sed "s/^.*=//"`

MINIMUM_PARTICIPATION_AMOUNT=`grep ^MINIMUM_PARTICIPATION_AMOUNT= settings.txt | sed "s/^.*=//"`
MAXIMUM_PARTICIPATION_AMOUNT=`grep ^MAXIMUM_PARTICIPATION_AMOUNT= settings.txt | sed "s/^.*=//"`
PRESALE_MINIMUM_FUNDING=`grep ^PRESALE_MINIMUM_FUNDING= settings.txt | sed "s/^.*=//"`
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
printf "TEST2OUTPUT                  = '$TEST2OUTPUT'\n"
printf "TEST2RESULTS                 = '$TEST2RESULTS'\n"
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
printf "CURRENTTIMEM5M               = '$CURRENTTIMEM5M' '$CURRENTTIMEM5MS'\n"
printf "CURRENTTIMEP1M               = '$CURRENTTIMEP1M' '$CURRENTTIMEP1MS'\n"
printf "CURRENTTIMEP5M               = '$CURRENTTIMEP5M' '$CURRENTTIMEP5MS'\n"
printf "CURRENTTIMEP10M              = '$CURRENTTIMEP10M' '$CURRENTTIMEP10MS'\n"

# --- Make copy of SOL file and strip out comments ---
`cp $SIKOBAPRESALESOL $SIKOBAPRESALETEMPSOL`
`perl -pi -e "s/^\/\*.*$//; s/^ \*.*$//; " $SIKOBAPRESALETEMPSOL`

# --- Modify dates ---
# PRESALE_START_DATE = +1m
`perl -pi -e "s/PRESALE_START_DATE = 1491393600;/PRESALE_START_DATE = $CURRENTTIMEM5M; \/\/ $CURRENTTIMEM5MS/" $SIKOBAPRESALETEMPSOL`
# PRESALE_END_DATE = +5m
`perl -pi -e "s/PRESALE_END_DATE = PRESALE_START_DATE \+ 2 weeks;/PRESALE_END_DATE = $CURRENTTIMEP10M; \/\/ $CURRENTTIMEP10MS/" $SIKOBAPRESALETEMPSOL`
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

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee $TEST2OUTPUT
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

// Test 2 contract setup
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
  console.log("RESULT: FAIL Test 2 Contract Setup");
} else {
  console.log("RESULT: PASS Test 2 Contract Setup");
}

// Test 2.1 Participant cannot contribute below minimum amount
var sendContribution21TxId = eth.sendTransaction({from: presaleParticipant1Account, to: sikobaPresaleAddress, value: web3.toWei(1, "ether"), gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("sendContribution21TxId", sendContribution21TxId);
printBalances();
gas = eth.getTransaction(sendContribution21TxId).gas;
gasUsed = eth.getTransactionReceipt(sendContribution21TxId).gasUsed;
if (gas == gasUsed) {
  console.log("RESULT: PASS Test 2.1 Participant cannot contribute below minimum amount");
} else {
  console.log("RESULT: FAIL Test 2.1 Participant cannot contribute below minimum amount");
}

// Test 2.2 Participant cannot contribute above maximum amount
var sendContribution22TxId = eth.sendTransaction({from: presaleParticipant1Account, to: sikobaPresaleAddress, value: web3.toWei(1000, "ether"), gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("sendContribution22TxId", sendContribution22TxId);
printBalances();
gas = eth.getTransaction(sendContribution22TxId).gas;
gasUsed = eth.getTransactionReceipt(sendContribution22TxId).gasUsed;
if (gas == gasUsed) {
  console.log("RESULT: PASS Test 2.2 Participant cannot contribute above maximum amount");
} else {
  console.log("RESULT: FAIL Test 2.2 Participant cannot contribute above maximum amount");
}

// Test 2.3 Participant can contribute in correct range
var sendContribution23TxId = eth.sendTransaction({from: presaleParticipant1Account, to: sikobaPresaleAddress, value: web3.toWei(100, "ether"), gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("sendContribution23TxId", sendContribution23TxId);
printBalances();
gas = eth.getTransaction(sendContribution23TxId).gas;
gasUsed = eth.getTransactionReceipt(sendContribution23TxId).gasUsed;
if (gas == gasUsed) {
  console.log("RESULT: FAIL Test 2.3 Participant can contribute in correct range");
} else {
  console.log("RESULT: PASS Test 2.3 Participant can contribute in correct range");
}

// Test 2.4 Participant cannot contribute once funding max reached
var sendContribution24TxId = eth.sendTransaction({from: presaleParticipant1Account, to: sikobaPresaleAddress, value: web3.toWei(700, "ether"), gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("sendContribution24TxId", sendContribution24TxId);
printBalances();
gas = eth.getTransaction(sendContribution24TxId).gas;
gasUsed = eth.getTransactionReceipt(sendContribution24TxId).gasUsed;
if (gas == gasUsed) {
  console.log("RESULT: PASS Test 2.4 Participant cannot contribute once funding max reached");
} else {
  console.log("RESULT: FAIL Test 2.4 Participant cannot contribute once funding max reached");
}

// Test 2.5 Owner cannot withdraw
var withdraw25TxId = sikobaPresale.ownerWithdraw(web3.toWei(100, "ether"), {from: ownerAccount, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("withdraw25TxId", withdraw25TxId);
printBalances();
gas = eth.getTransaction(withdraw25TxId).gas;
gasUsed = eth.getTransactionReceipt(withdraw25TxId).gasUsed;
if (gas == gasUsed) {
  console.log("RESULT: PASS Test 2.5 Owner cannot withdraw");
} else {
  console.log("RESULT: FAIL Test 2.5 Owner cannot withdraw");
}

// Test 2.6 Owner cannot clawback
var clawback26TxId = sikobaPresale.ownerClawback({from: ownerAccount, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("clawback26TxId", clawback26TxId);
printBalances();
gas = eth.getTransaction(clawback26TxId).gas;
gasUsed = eth.getTransactionReceipt(clawback26TxId).gasUsed;
if (gas == gasUsed) {
  console.log("RESULT: PASS Test 2.6 Owner cannot clawback");
} else {
  console.log("RESULT: FAIL Test 2.6 Owner cannot clawback");
}

// Test 2.7 Participant cannot withdraw
var balance = sikobaPresale.balanceOf(preallocationParticipant1Account);
console.log("RESULT: preallocationParticipant1Account balance=" + web3.fromWei(balance, "ether"));
var participantWithdraw27TxId = sikobaPresale.participantWithdrawIfMinimumFundingNotReached(web3.fromWei(1, "ether"), {from: preallocationParticipant1Account, gas: 100000});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("participantWithdraw27TxId", participantWithdraw27TxId);
gas = eth.getTransaction(participantWithdraw27TxId).gas;
gasUsed = eth.getTransactionReceipt(participantWithdraw27TxId).gasUsed;
if (gas == gasUsed) {
  console.log("RESULT: PASS Test 2.7 Participant cannot withdraw");
} else {
  console.log("RESULT: FAIL Test 2.7 Participant cannot withdraw");
}

EOF
grep "RESULT: " $TEST2OUTPUT | sed "s/RESULT: //" > $TEST2RESULTS
cat $TEST2RESULTS