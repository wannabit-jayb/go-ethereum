#!/usr/bin/env bats

# Current build.
: ${GETH_CMD:=$GOPATH/bin/geth --data-dir $GETH_TMP_DATA_DIR --lightkdf --verbosity 0 --display 0 --port 33333}
# EF go-ethereum for comparison
# : ${GETH_CMD:=$GOPATH/bin/mgeth --datadir $GETH_TMP_DATA_DIR --lightkdf --verbosity 0 --port 33333}

setup() {
	GETH_TMP_DATA_DIR=`mktemp -d`
	mkdir "$GETH_TMP_DATA_DIR/mainnet"
}

teardown() {
	rm -rf $GETH_TMP_DATA_DIR
}

@test "eth_sign1" {
    testacc=f466859ead1932d743d622cb74fc058882e8648a
		tesetacc_pass=foobar
		echo $tesetacc_pass > $GETH_TMP_DATA_DIR/pass.file

		# regex for successful signture
		success='0x[0-9a-f]{130}'

    run $GETH_CMD \
        --keystore $GOPATH/src/github.com/ethereumproject/go-ethereum/accounts/testdata/keystore \
        --unlock "$testacc" \
				--password "$GETH_TMP_DATA_DIR/pass.file" \
        --exec="eth.sign('"$testacc"', '0xdeadbeef');" console 2> /dev/null
		echo "$output"
		[ "$status" -eq 0 ]
    [[ "$output" =~ $success ]]
}

@test "eth_sign2" {
    testacc=f466859ead1932d743d622cb74fc058882e8648a
		tesetacc_pass=foobar
		echo $tesetacc_pass > $GETH_TMP_DATA_DIR/pass.file

		# regex for successful signture
		success='0x[0-9a-f]{130}'

    run $GETH_CMD \
        --keystore $GOPATH/src/github.com/ethereumproject/go-ethereum/accounts/testdata/keystore \
        --unlock "$testacc" \
				--password "$GETH_TMP_DATA_DIR/pass.file" \
        --exec="eth.sign('"$testacc"', web3.fromAscii('Schoolbus'));" console 2> /dev/null
		echo "$output"
		[ "$status" -eq 0 ]
    [[ "$output" =~ $success ]]
}

# This is a failing test. It also fails using ETH/Foundation/Multi geth, although
# the wiki documentation in all cases cites using "Schoolbus" as an example of arbitrary signable data.
# Turns out, you have to use 0x-prefixed hex data (hex string 'deadbeef' will also fail).
# @test "eth_sign_nohex" {
#     testacc=f466859ead1932d743d622cb74fc058882e8648a
# 		tesetacc_pass=foobar
# 		echo $tesetacc_pass > $GETH_TMP_DATA_DIR/pass.file
#
# 		# regex for successful signture
# 		success='0x[0-9a-f]{130}'
#
#     run $GETH_CMD \
#         --keystore $GOPATH/src/github.com/ethereumproject/go-ethereum/accounts/testdata/keystore \
#         --unlock "$testacc" \
# 				--password "$GETH_TMP_DATA_DIR/pass.file" \
#         --exec="eth.sign('"$testacc"', 'Schoolbus');" console 2> /dev/null
# 		echo "$output"
# 		[ "$status" -ne 0 ]
#     # [[ "$output" =~ $success ]]
# }