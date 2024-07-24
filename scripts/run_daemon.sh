cd ../daemon/builds/libs/
java -jar daemon-all.jar \
        --torControlPort=9077 \
        --torControlPassword=boner \
		--baseCurrencyNetwork=XMR_STAGENET \
		--useLocalhostForP2P=false \
		--useDevPrivilegeKeys=false \
		--nodePort=9999 \
		--appName=haveno-XMR_STAGENET_user1 \
		--apiPassword=apitest \
		--apiPort=3201 \
		--passwordRequired=false \
		--useNativeXmrWallet=false \