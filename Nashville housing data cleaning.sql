SELECT *
FROM [NashvilleHousing]


----------------------------------Standardize Date Format
SELECT SaleDateConverted, CONVERT(date,saledate)
FROM [NashvilleHousing]

UPDATE [NashvilleHousing]
SET SaleDate = CONVERT(date,saledate)

ALTER TABLE [NashvilleHousing]
ADD SaleDateConverted date;

UPDATE [NashvilleHousing]
SET SaleDateConverted = CONVERT(date,saledate)



----------------------------------Populate property address data

SELECT PropertyAddress
FROM [NashvilleHousing]
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [NashvilleHousing] a
JOIN [NashvilleHousing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [NashvilleHousing] a
JOIN [NashvilleHousing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


------------------------------------Breaking out Address into individual columns (Address, City, State)

SELECT SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
		SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM [NashvilleHousing]




ALTER TABLE [NashvilleHousing]
ADD Address_split nvarchar(250);

UPDATE [NashvilleHousing]
SET Address_split = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE [NashvilleHousing]
ADD City_split nvarchar(250);

UPDATE [NashvilleHousing]
SET City_split = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


--------------------------------Alternative to substring function, breaking out Owner Address into individual columns (address, city, states)

SELECT 
PARSENAME (REPLACE(OwnerAddress,',','.'), 3),
PARSENAME (REPLACE(OwnerAddress,',','.'), 2),
PARSENAME (REPLACE(OwnerAddress,',','.'), 1)
FROM [NashvilleHousing]

ALTER TABLE [NashvilleHousing]
ADD Owner_address_split nvarchar(250);

UPDATE [NashvilleHousing]
SET Owner_address_split = PARSENAME (REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE [NashvilleHousing]
ADD Owner_city_split nvarchar(250);

UPDATE [NashvilleHousing]
SET Owner_city_split = PARSENAME (REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE [NashvilleHousing]
ADD Owner_state_split nvarchar(250);

UPDATE [NashvilleHousing]
SET Owner_state_split = PARSENAME (REPLACE(OwnerAddress,',','.'), 1)

SELECT *
FROM NashvilleHousing




------------------------------------change Y and N to Yes and No to vacant field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
	FROM [NashvilleHousing]
	GROUp BY SoldAsVacant
	ORDER BY 2


SELECT Soldasvacant
, CASE WHEN SoldasVacant = 'Y' then 'Yes'
		WHEN SoldasVacant = 'N' then 'No'
		ELSE SoldasVacant
		END
FROM [NashvilleHousing]

UPDATE [NashvilleHousing]
SET SoldAsVacant = CASE WHEN SoldasVacant = 'Y' then 'Yes'
		WHEN SoldasVacant = 'N' then 'No'
		ELSE SoldasVacant
		END


--------------------------------------------Remove duplicates

WITH RowNumCTE AS 
(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				ORDER BY UniqueID
				)row_num
FROM [NashvilleHousing]
)
DELETE
FROM RowNumCTE
WHERE row_num > 1



--------------------------------------Remove unused columns

ALTER TABLE [NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT *
FROM [NashvilleHousing]