CREATE TABLE `testDB`.`Penna` ( 
  `ID` INT NOT NULL, 
  `Timestamp` DATETIME NULL, 
  `state` VARCHAR(45) NULL, 
  `locality` VARCHAR(45) NULL, 
  `precinct` VARCHAR(45) NULL, 
  `geo` VARCHAR(45) NULL, 
  `totalvotes` INT NULL, 
  `Biden` INT NULL, 
  `Trump` INT NULL, 
  `filestamp` VARCHAR(45) NULL, 
  PRIMARY KEY (`ID`));
  
  