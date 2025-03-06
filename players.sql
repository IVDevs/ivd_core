CREATE TABLE `players` (
  `ID` int NOT NULL,
  `RockstarID` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `money` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '{"bank":100,"cash":100,"black_money":0}',
  `Items` varchar(1000) NOT NULL DEFAULT '{}',
  `Weapons` varchar(100) NOT NULL DEFAULT '{}',
  `Health` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '{"health":200,"armour":200}',
  `Job` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'Unemployed',
  `Grade` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0',
  `position` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '{"x":-222.98,"y":430.16,"z":14.82,"h":122.23}'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

ALTER TABLE `players`
  ADD PRIMARY KEY (`ID`);