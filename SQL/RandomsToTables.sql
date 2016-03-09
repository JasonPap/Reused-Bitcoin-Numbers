/****** Script for Initializing Randoms and BadRandoms tables  ******/
USE MyBitcoinData

-- Create table to store random numbers used
IF OBJECT_ID('dbo.Randoms', 'U') IS NOT NULL 
  DROP TABLE dbo.Randoms; 

CREATE TABLE [dbo].[Randoms]
(
	TransactionInputId BIGINT PRIMARY KEY,
	Random	VARBINARY(40) NOT NULL
);

print N'Randoms table created';

-- Parse input scripts and populate table with all the randoms used
INSERT INTO [MyBitcoinData].[dbo].[Randoms]
SELECT TransactionInputId,
	CASE
		WHEN SUBSTRING(InputScript,2,1) = 0x30 THEN CASE
														WHEN SUBSTRING(InputScript,4,2) = 0x0214 THEN SUBSTRING(InputScript,6,20)
														WHEN SUBSTRING(InputScript,4,2) = 0x0215 THEN SUBSTRING(InputScript,6,21)
														WHEN SUBSTRING(InputScript,4,2) = 0x0216 THEN SUBSTRING(InputScript,6,22)
														WHEN SUBSTRING(InputScript,4,2) = 0x0217 THEN SUBSTRING(InputScript,6,23)
														WHEN SUBSTRING(InputScript,4,2) = 0x0218 THEN SUBSTRING(InputScript,6,24)
														WHEN SUBSTRING(InputScript,4,2) = 0x0219 THEN SUBSTRING(InputScript,6,25)
														WHEN SUBSTRING(InputScript,4,2) = 0x021A THEN SUBSTRING(InputScript,6,26)
														WHEN SUBSTRING(InputScript,4,2) = 0x021B THEN SUBSTRING(InputScript,6,27)
														WHEN SUBSTRING(InputScript,4,2) = 0x021C THEN SUBSTRING(InputScript,6,28)
														WHEN SUBSTRING(InputScript,4,2) = 0x021D THEN SUBSTRING(InputScript,6,29)
														WHEN SUBSTRING(InputScript,4,2) = 0x021E THEN SUBSTRING(InputScript,6,30)
														WHEN SUBSTRING(InputScript,4,2) = 0x021F THEN SUBSTRING(InputScript,6,31)
														WHEN SUBSTRING(InputScript,4,2) = 0x0220 THEN SUBSTRING(InputScript,6,32)
														WHEN SUBSTRING(InputScript,4,2) = 0x0221 THEN SUBSTRING(InputScript,7,32)
														WHEN SUBSTRING(InputScript,4,2) = 0x0222 THEN SUBSTRING(InputScript,8,32)
													 END
		ELSE CASE --for scripts where the second byte is not 0x30
				WHEN SUBSTRING(InputScript,3,1) = 0x30 THEN CASE
																WHEN SUBSTRING(InputScript,5,2) = 0x0214 THEN SUBSTRING(InputScript,6,20)
																WHEN SUBSTRING(InputScript,5,2) = 0x0215 THEN SUBSTRING(InputScript,6,21)
																WHEN SUBSTRING(InputScript,5,2) = 0x0216 THEN SUBSTRING(InputScript,6,22)
																WHEN SUBSTRING(InputScript,5,2) = 0x0217 THEN SUBSTRING(InputScript,6,23)
																WHEN SUBSTRING(InputScript,5,2) = 0x0218 THEN SUBSTRING(InputScript,6,24)
																WHEN SUBSTRING(InputScript,5,2) = 0x0219 THEN SUBSTRING(InputScript,6,25)
																WHEN SUBSTRING(InputScript,5,2) = 0x021A THEN SUBSTRING(InputScript,6,26)
																WHEN SUBSTRING(InputScript,5,2) = 0x021B THEN SUBSTRING(InputScript,6,27)
																WHEN SUBSTRING(InputScript,5,2) = 0x021C THEN SUBSTRING(InputScript,6,28)
																WHEN SUBSTRING(InputScript,5,2) = 0x021D THEN SUBSTRING(InputScript,6,29)
																WHEN SUBSTRING(InputScript,5,2) = 0x021E THEN SUBSTRING(InputScript,6,30)
																WHEN SUBSTRING(InputScript,5,2) = 0x021F THEN SUBSTRING(InputScript,6,31)
																WHEN SUBSTRING(InputScript,5,2) = 0x0220 THEN SUBSTRING(InputScript,6,32)
																WHEN SUBSTRING(InputScript,5,2) = 0x0221 THEN SUBSTRING(InputScript,7,32)
																WHEN SUBSTRING(InputScript,5,2) = 0x0222 THEN SUBSTRING(InputScript,8,32)
															END
			 END		
	END as Random
FROM dbo.TransactionInputSource
WHERE
SourceTransactionOutputIndex >=0
AND
(	
	(SUBSTRING(InputScript,2,1) = 0x30 AND SUBSTRING(InputScript,4,2) IN (0x0214, 0x0215, 0x0216, 0x0217, 0x0218, 0x0219, 0x021A, 0x021B,
																		0x021C, 0x021D, 0x021E, 0x021F, 0x0220, 0x0221, 0x0222) 
	)
	OR
	(SUBSTRING(InputScript,3,1) = 0x30 AND SUBSTRING(InputScript,5,2) IN (0x0214, 0x0215, 0x0216, 0x0217, 0x0218, 0x0219, 0x021A, 0x021B,
																		0x021C, 0x021D, 0x021E, 0x021F, 0x0220, 0x0221, 0x0222) 
	)
)

print N'Randoms table filled with data'; 

-- Create index on Random values for faster access
CREATE NONCLUSTERED INDEX Random_Index ON Randoms(Random);

print N'Index on Randoms created';

-- Create table to store random numbers used more than once
IF OBJECT_ID('dbo.BadRandoms', 'U') IS NOT NULL 
  DROP TABLE dbo.BadRandoms;

CREATE TABLE [dbo].[BadRandoms]
(
	--BadRandomId INT PRIMARY KEY,
	Random	VARBINARY(40) PRIMARY KEY,
	UseCount INT NOT NULL
);

print N'BadRandoms table created';

-- Find all randoms used more than once and store them in the BadRandoms table
INSERT INTO [MyBitcoinData].[dbo].[BadRandoms]
SELECT Random, count(*) as UseCount 
	FROM [MyBitcoinData].[dbo].[Randoms] 
	GROUP BY Random HAVING count(*) > 1 
	--ORDER BY TimesUsed DESC

print N'BadRandoms table filled with data';