/******************************************************************************************************************************
													CLEANING DATA IN SQL QUERIES
******************************************************************************************************************************/

SELECT * FROM PortfolioProjects..nashvilleHouse;

--------------------------------------------------------------------------------------------------------------------------

	-------------------------------------------	STANDARDIZE DATA FORMAT	--------------------------------------------
SELECT SaleDateConverted, CONVERT(Date, SaleDate) 
FROM PortfolioProjects..nashvilleHouse;

UPDATE nashvilleHouse
SET SaleDate = CONVERT(Date, SaleDate);

ALTER TABLE nashvilleHouse
ADD SaleDateConverted Date;

UPDATE nashvilleHouse
SET SaleDateConverted = CONVERT(Date, SaleDate);




	------------------------------------------------------	PROPERTY ADDRESS	----------------------------------------------------------------

SELECT *
FROM PortfolioProjects..nashvilleHouse
--WHERE PropertyAddress IS NULL;
ORDER BY ParcelID;

---Populating Null entries in PropertyAddress with reference values of PropertyAdress and ParcelID using self-join
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects..nashvilleHouse a
JOIN PortfolioProjects..nashvilleHouse b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] --meaning a.[UniqueID ] IS NOT EQUAL TO b.[UniqueID ] 
WHERE a.PropertyAddress IS NULL;


--Updating the PropertyAddress column
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects..nashvilleHouse a
JOIN PortfolioProjects..nashvilleHouse b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE a.PropertyAddress IS NULL;




	-------------------------------------------	SPLITTING ADDRESS INTO INDIVIDUAL COLUMNS(ADDRESS, CITY, STATE) --------------------------------------------

SELECT PropertyAddress
FROM PortfolioProjects..nashvilleHouse
-- '2312  ALTERAS DR, NASHVILLE' is an example of a property address that has Address, city and state separated by 'DR' and ','


--using substring and character index
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, -- the '-1' removes the ','
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address 
FROM PortfolioProjects..nashvilleHouse;

ALTER TABLE nashvilleHouse
ADD PropertySplitAddress NVARCHAR(255);

UPDATE nashvilleHouse
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);


ALTER TABLE nashvilleHouse
ADD PropertySplitCity NVARCHAR(255);

UPDATE nashvilleHouse
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

SELECT * 
FROM PortfolioProjects..nashvilleHouse;	--view changes as last 2 rows



---Working with 'OwnerAddress' in a similar way with PropertyAddress
SELECT OwnerAddress
FROM PortfolioProjects..nashvilleHouse
WHERE OwnerAddress IS NOT NULL; --Owner address is still as city, address and state 

--using PARSENAME to split the address
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),--REPLACING ',' WITH A '.'
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM PortfolioProjects..nashvilleHouse


ALTER TABLE nashvilleHouse
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE nashvilleHouse
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3);


ALTER TABLE nashvilleHouse
ADD OwnerSplitCity NVARCHAR(255);

UPDATE nashvilleHouse
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2);

ALTER TABLE nashvilleHouse
ADD OwnerSplitState NVARCHAR(255);


UPDATE nashvilleHouse
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1);







	-------------------------------------------	CHANGE 'Y' AND 'N' TO 'YES' AND 'NO' IN 'SoldAsVacant' --------------------------------------------

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS NumberOfVacant
FROM PortfolioProjects..nashvilleHouse
GROUP BY SoldAsVacant
ORDER BY 2;




SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' --When sold as vacant is Y, theb it is Yes
			WHEN SoldAsVacant = 'N' THEN 'No' --When sold as vacant is N, theb it is No
			ELSE SoldAsVacant --Else, keep it as it is, SoldAsVacant
			END
FROM PortfolioProjects..nashvilleHouse



UPDATE nashvilleHouse
SET SoldAsVacant = 	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' --When sold as vacant is Y, theb it is Yes
			WHEN SoldAsVacant = 'N' THEN 'No' --When sold as vacant is N, theb it is No
			ELSE SoldAsVacant --Else, keep it as it is, SoldAsVacant
			END



				-------------------------------------------------	REMOVE DUPLICATES  ----------------------------------------------------
	--With CTEs and Windows Functions highlighting the duplicate
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY ParcelID,						-- partitioning by things that are unique to each row
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) row_num
FROM PortfolioProjects..nashvilleHouse
)
---Deleting the duplicate
DELETE
FROM RowNumCTE
WHERE row_num > 1






	-------------------------------------------------	DELETING UNUSED COLUMNS  ----------------------------------------------------

SELECT *
FROM PortfolioProjects..nashvilleHouse

ALTER TABLE PortfolioProjects..nashvilleHouse
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProjects..nashvilleHouse
DROP COLUMN SaleDate;


SELECT * FROM PortfolioProjects..nashvilleHouse;
