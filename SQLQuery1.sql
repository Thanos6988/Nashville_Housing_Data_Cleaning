--Cleaning data in SQL queries

--Standardize date format

select convert(date,SaleDate)
from dbo.NashvilleHousing

update dbo.NashvilleHousing
set SaleDate = convert(date,SaleDate)

select SaleDate
from dbo.NashvilleHousing

alter table dbo.NashvilleHousing
add SaleDateConverted Date

update dbo.NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN SaleDate;

select *
from dbo.NashvilleHousing

--Populate Propery Address data

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from dbo.NashvilleHousing a
join dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from dbo.NashvilleHousing a
join dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out Address into individual columns(Address,City,State)

select PropertyAddress
from dbo.NashvilleHousing 

select substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) as Address,
substring(PropertyAddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
from dbo.NashvilleHousing

--alternatively

select PARSENAME(replace(PropertyAddress,',','.'),2),
PARSENAME(replace(PropertyAddress,',','.'),1)
from dbo.NashvilleHousing

alter table dbo.NashvilleHousing
add PropertySplitAddress nvarchar(255)

update dbo.NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)

alter table dbo.NashvilleHousing
add PropertySplitCity nvarchar(255)

update dbo.NashvilleHousing
set PropertySplitCity = substring(PropertyAddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress))

select *
from dbo.NashvilleHousing

---

select OwnerAddress
from dbo.NashvilleHousing

select PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from dbo.NashvilleHousing

alter table dbo.NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table dbo.NashvilleHousing
add OwnerSplitCity nvarchar(255)

update dbo.NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table dbo.NashvilleHousing
add OwnerSplitState nvarchar(255)

update dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

select *
from dbo.NashvilleHousing

-- Change 'Y' and 'N' to Yes and No in Sold as Vacant column

select distinct(SoldAsVacant),count(SoldAsVacant)
from dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
     end 
from dbo.NashvilleHousing


alter table dbo.NashvilleHousing
add SoldAsVacantUpdated nvarchar(3)

update dbo.NashvilleHousing
set SoldAsVacantUpdated = case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
     end 

select distinct(SoldAsVacantUpdated),count(SoldAsVacantUpdated)
from dbo.NashvilleHousing
group by SoldAsVacantUpdated
order by 2

--Remove Duplicates

with RowNumCTE as(
select *,
ROW_NUMBER() over (
partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDateConverted,
			 LegalReference
			 order by
			 UniqueID
			 ) row_num
from dbo.NashvilleHousing
--order by ParcelID
)

--select *	
--from RowNumCTE
--where row_num > 1

delete
from RowNumCTE
where row_num > 1



