SELECT * 
FROM PortfolioProject1..NashvilleHousing

--Reformating date format to get rid of unnecessary time 

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject1..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject1..NashvilleHousing

--Populating Property address data

SELECT *
FROM PortfolioProject1..NashvilleHousing
WHERE PropertyAddress IS NULL

--[Takes a look at the dat in which parcel IDs contain both null and address.]
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject1..NashvilleHousing a
JOIN PortfolioProject1..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Updating database to remove null values and change property addresses for identical Parcel IDs to have the same address
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject1..NashvilleHousing a
JOIN PortfolioProject1..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Reformating Addresses to have individual columns for streeet, city, and state
 SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
 FROM PortfolioProject1..NashvilleHousing

 ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

 ALTER TABLE NashvilleHousing
ADD PropertyCityAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertyCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

--Looking at owner addresses and reformating using PARSENAME
SELECT OwnerAddress
FROM PortfolioProject1..NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as STATE,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS CITY,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS STREET
FROM PortfolioProject1..NashvilleHousing

 ALTER TABLE NashvilleHousing
ADD OwnerStreetAddress NVARCHAR(255);

 ALTER TABLE NashvilleHousing
ADD OwnerCityAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerStateAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET OwnerStateAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Replacing wrong formatting for yes/no options (Y/N to YES/NO)
SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject1..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

--Removing duplicate data
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) 
					row_num
From PortfolioProject1..NashvilleHousing
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

DELETE
From RowNumCTE
Where row_num > 1

--Deleting unused columns
Select *
From PortfolioProject1..NashvilleHousing

ALTER TABLE PortfolioProject1..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From PortfolioProject1..NashvilleHousing
