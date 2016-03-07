#!/usr/bin/python2
import pymssql #install from http://www.lfd.uci.edu/~gohlke/pythonlibs/#pymssql

conn = pymssql.connect(	server='86.169.104.93:50507', user='cryptanalysis',	password='Blockchain123', database='MyBitcoinData')
# 127.0.0.1

htmlstart = """
	<!DOCTYPE html>
	<html>
	<head>
	<title>Repeated randoms used in the Bitcoin Blockchain</title>
	<meta name="author" content="Jason Papapanagiotakis">
	</head>
	<body>
	<h1>Repeated random numbers used in the Bitcoin Blockchain</h1>
	<table border="1" cellpadding="3" cellspacing="3">
"""

htmlend = """
	</table>
	</body>
	</html>
""" 

dbquery = """
  USE MyBitcoinData
  SELECT BR.Random , B.TransactionHash , TI.InputScriptId 
  FROM dbo.BadRandoms BR
  LEFT JOIN Randoms R ON R.Random = BR.Random
  LEFT JOIN dbo.TransactionInput TI ON R.TransactionInputId = TI.TransactionInputId
  LEFT JOIN dbo.BitcoinTransaction B ON B.BitcoinTransactionId = TI.BitcoinTransactionId
  WHERE BR.Random != 0x3B78CE563F89A0ED9414F5AA28AD0D96D6795F9C63
  ORDER BY BR.Random DESC
"""
webpage = htmlstart
badrand = conn.cursor()
# get the bad randoms from Database
badrand.execute(dbquery)

row = badrand.fetchone()
webpage += "<tr><td><b>Random number</b></td><td><b>Transaction Hash : input script index</b>"
previous_random = ""
transactionHashes = dict() # key: transaction hash , value: list of input scripts IDs that have the bad random number 
while row:
	current_random = str(row[0].encode("hex"))
	current_transaction_hash = str(row[1].encode("hex"))
	current_iscript_id = str(row[2])
	if current_random != previous_random:
		previous_random = current_random
		sth = ""
		for th in transactionHashes:
			sth += "<a href=\"https://blockchain.info/tx/" + th + "\">" + th + "</a>" 
			sth += " : i" + ' ,i'.join(transactionHashes[th]) + "<br>"
		webpage += sth + "</td></tr>" 
		webpage += "<tr><td>" + str(row[0].encode("hex")) + "</td><td>"
		transactionHashes.clear()
		transactionHashes[current_transaction_hash] = [current_iscript_id]
	else:
		if current_transaction_hash in transactionHashes:
			transactionHashes[current_transaction_hash].append(current_iscript_id)
		else:
			transactionHashes[current_transaction_hash] = [current_iscript_id]
	row = badrand.fetchone()

sth = ""
for th in transactionHashes:
	sth += th + ' ,i'.join(transactionHashes[th]) + "<br>"
webpage += sth + "</td></tr>" 
webpage += htmlend

# create the webpage 
with open("index.html", "w") as f:
	f.write(webpage)

print "done"
