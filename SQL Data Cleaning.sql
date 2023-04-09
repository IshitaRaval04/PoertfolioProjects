/*

Cleaning Data with SQL Queries

*/


Select*
From [PortfolioProject-2].dbo.NashvilleHousing

------------------------------------------------------------------------------------------

--Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate) as SaleDate2
From [PortfolioProject-2].dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--Another way to execute the queries to get Standardize date format

/*
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate) 
*/

-----------------------------------------------------------------------------------------

--Populate Property Address Data

/*Since property address contains NULL values we would convert it by using the Parcel ID are equal
then property Address of that parcel ID would be same */

Select PropertyAddress
From [PortfolioProject-2].dbo.NashvilleHousing
where PropertyAddress is Null

Select *
From [PortfolioProject-2].dbo.NashvilleHousing
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [PortfolioProject-2].dbo.NashvilleHousing a
JOIN [PortfolioProject-2].dbo.NashvilleHousing b
on a.ParcelID= b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [PortfolioProject-2].dbo.NashvilleHousing a
JOIN [PortfolioProject-2].dbo.NashvilleHousing b
on a.ParcelID= b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-----------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From [PortfolioProject-2].dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))  as Address
From [PortfolioProject-2].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySpiltAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySpiltAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 



ALTER TABLE NashvilleHousing
ADD PropertySpiltCity Nvarchar(255); 

Update NashvilleHousing
SET PropertySpiltCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
From [PortfolioProject-2].dbo.NashvilleHousing

--OWNER ADDRESS

SELECT OwnerAddress
From [PortfolioProject-2].dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE (OwnerAddress,',','.') ,3)
,PARSENAME(REPLACE (OwnerAddress,',','.') ,2)
,PARSENAME(REPLACE (OwnerAddress,',','.') ,1)
From [PortfolioProject-2].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255); 

Update NashvilleHousing
SET OwnerSplitAddress= PARSENAME(REPLACE (OwnerAddress,',','.') ,3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255); 

Update NashvilleHousing
SET OwnerSplitCity= PARSENAME(REPLACE (OwnerAddress,',','.') ,2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255); 

Update NashvilleHousing
SET OwnerSplitState= PARSENAME(REPLACE (OwnerAddress,',','.') ,1)

SELECT *
From [PortfolioProject-2].dbo.NashvilleHousing

---------------------------------------------------------------------------------

--Chnage Y and N to Yes and No in "Solid as Vacant" Field

SELECT Distinct(SoldAsVacant), Count(SoldAsVAcant)
From [PortfolioProject-2].dbo.NashvilleHousing
Group by SoldAsVacant
Order by SoldAsVacant


Select SoldAsVacant
,CASE when SoldAsVacant= 'Y' THEN 'Yes'
      when SoldAsVacant= 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
From [PortfolioProject-2].dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant= CASE when SoldAsVacant= 'Y' THEN 'Yes'
      when SoldAsVacant= 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END


----------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY UniqueID
			   ) row_num
From [PortfolioProject-2].dbo.NashvilleHousing
)
/*Select*    Here we checked for the duplicates and then using the DELETE keyword instead of select deleted them and when we run again with the select statemetn it will show no data just column names
FROM RowNumCTE
where row_num>1
order by PropertyAddress*/
DELETE
FROM RowNumCTE
where row_num>1

select*
From [PortfolioProject-2].dbo.NashvilleHousing

----------------------------------------------------------------------------------------------

--Delete Unused Columns

select*
From [PortfolioProject-2].dbo.NashvilleHousing


ALTER TABLE [PortfolioProject-2].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict


ALTER TABLE [PortfolioProject-2].dbo.NashvilleHousing
DROP COLUMN SaleDate

