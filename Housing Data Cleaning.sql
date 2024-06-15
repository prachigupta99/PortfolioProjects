--Cleaning data in SQL queries

Select *
From PortfolioProject1.dbo.NashvilleHousing

--Standardize date format
Select SaleDateConverted , CONVERT(date, SaleDate) 
From PortfolioProject1.dbo.NashvilleHousing;

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET SaleDate =  CONVERT(date, SaleDate)

--If doesn't update properly

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
ADD SaleDateConverted date;

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET SaleDateConverted  =  CONVERT(date, SaleDate)

--Populate property address data
Select *
From PortfolioProject1.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject1.dbo.NashvilleHousing a
Join PortfolioProject1.dbo.NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
	 WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject1.dbo.NashvilleHousing a
Join PortfolioProject1.dbo.NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
	 WHERE a.PropertyAddress is NULL

--Breaking out address into individual columns (Address, City, State)
Select PropertyAddress
From PortfolioProject1.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress)) AS Address
From PortfolioProject1.dbo.NashvilleHousing

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar (255);

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET PropertySplitAddress  =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1)

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar (255);

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET PropertySplitCity  =  SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject1.dbo.NashvilleHousing


Select OwnerAddress
From PortfolioProject1.dbo.NashvilleHousing

Select
PARSENAME (REPLACE (OwnerAddress, ',' , '.') , 3),
PARSENAME (REPLACE (OwnerAddress, ',' , '.') , 2),
PARSENAME (REPLACE (OwnerAddress, ',' , '.') , 1)
From PortfolioProject1.dbo.NashvilleHousing


ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar (255);

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET OwnerSplitAddress  =  PARSENAME (REPLACE (OwnerAddress, ',' , '.') , 3)

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar (255);

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET OwnerSplitCity  = PARSENAME (REPLACE (OwnerAddress, ',' , '.') , 2)


ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar (255);

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET OwnerSplitState  =  PARSENAME (REPLACE (OwnerAddress, ',' , '.') , 1)

Select *
From PortfolioProject1.dbo.NashvilleHousing




--Change Y and N to 'Yes' and 'No' in 'Sold as Vacant' field
Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject1.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



Select SoldAsVacant,
CASE
   WHEN SoldAsVacant = 'Y' THEN 'Yes'
   WHEN SoldAsVacant = 'N' THEN 'No'
   ELSE SoldAsVacant
   END
From PortfolioProject1.dbo.NashvilleHousing

UPDATE  PortfolioProject1.dbo.NashvilleHousing
SET SoldAsVacant = CASE
   WHEN SoldAsVacant = 'Y' THEN 'Yes'
   WHEN SoldAsVacant = 'N' THEN 'No'
   ELSE SoldAsVacant
   END 


--Removing duplicates
WITH RowNumCTE AS (
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID) row_num
From PortfolioProject1.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
From RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


--Checking to see if duplicates are removed
WITH RowNumCTE AS (
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID) row_num
From PortfolioProject1.dbo.NashvilleHousing
--ORDER BY ParcelID
)
Select *
From RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

Select *
From PortfolioProject1.dbo.NashvilleHousing


--Deleting unused columns


Select *
From PortfolioProject1.dbo.NashvilleHousing

ALter TABLE PortfolioProject1.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress 


ALter TABLE PortfolioProject1.dbo.NashvilleHousing
DROP COLUMN SaleDate