/*
Cleaning Data
*/

select *
from PortfolioProject.nashvillehousingdata;

-- ----------------------------------------------------------------------------

-- Standardizing Date Format
select SaleDate, str_to_date(SaleDate, '%M %e, %Y') ConvertedDate
from PortfolioProject.nashvillehousingdata;

alter table nashvillehousingdata
add column new_date date,
add index idx_saldat(SaleDate(255));
  
update nashvillehousingdata
set new_date = str_to_date(SaleDate, '%M %e, %Y')
where SaleDate is not null;

alter table nashvillehousingdata
drop column SaleDate,
rename column new_date to SaleDate;

-- ----------------------------------------------------------------------------

-- Populate Property Address Data
select PropertyAddress, 'This row contains an empty string' Indicator
from PortfolioProject.nashvillehousingdata
where PropertyAddress = '';

-- Parcel IDs repeat multiple times in different rows, so doing a self join of the table to explicitly view these
-- Thus, we can check the property addresses that are empty
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject.nashvillehousingdata a
join PortfolioProject.nashvillehousingdata b
	on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress = '';

-- That was just to show the idea, now let's actually do it
alter table PortfolioProject.nashvillehousingdata
add index idx_propaddr(PropertyAddress(255));

update PortfolioProject.nashvillehousingdata a
join PortfolioProject.nashvillehousingdata b
	on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
set a.PropertyAddress = b.PropertyAddress
where a.PropertyAddress = '';

-- ----------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
select PropertyAddress
from PortfolioProject.nashvillehousingdata;


-- The addresses are formatted in the following manner: Local Address, City
-- So what we will do is look for the comma and separate the address according to that
select substring(PropertyAddress, 1, locate(',', PropertyAddress) - 1) Address,
substring(PropertyAddress, locate(',', PropertyAddress) + 2, char_length(PropertyAddress)) City
from PortfolioProject.nashvillehousingdata;

-- Now let's actually create the new columns
alter table PortfolioProject.nashvillehousingdata
add column new_address text,
add column City text;

update PortfolioProject.nashvillehousingdata
set new_address = substring(PropertyAddress, 1, locate(',', PropertyAddress) - 1),
	City = substring(PropertyAddress, locate(',', PropertyAddress) + 2, char_length(PropertyAddress))
where PropertyAddress <> '';

alter table PortfolioProject.nashvillehousingdata
rename column new_address to PropertySplitAddress,
rename column City to PropertySplitCity;

-- Now we will do some similar splitting for OwnerAddress
-- We will use substring_index this time
select substring_index(OwnerAddress, ',', 1), 
substring_index(substring_index(OwnerAddress, ',', 2), ',', -1),
substring_index(OwnerAddress, ',', -1)
from PortfolioProject.nashvillehousingdata;

-- Time to actually make the changes
alter table PortfolioProject.nashvillehousingdata
add index idx_owneaddr(OwnerAddress(255)), 
add column OwnerSplitAddress text,
add column OwnerSplitCity text,
add column OwnerSplitState text;

update PortfolioProject.nashvillehousingdata
set OwnerSplitAddress = substring_index(OwnerAddress, ',', 1),
	OwnerSplitCity = substring_index(substring_index(OwnerAddress, ',', 2), ',', -1),
	OwnerSplitState = substring_index(OwnerAddress, ',', -1)
where OwnerAddress is not null;

-- ----------------------------------------------------------------------------

-- Change Y and N to Yes and No in SoldAsVacant field
-- Checking number of occurences of Y and N
select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.nashvillehousingdata
group by SoldAsVacant
order by 2;

-- Making the changes
alter table PortfolioProject.nashvillehousingdata
add index idx_solvac(SoldAsVacant(255));

update PortfolioProject.nashvillehousingdata
set SoldAsVacant = case
	when SoldAsVacant = 'Y' then 'Yes'
    when SoldAsVacant = 'N' then 'No'
    else SoldAsVacant
end
where SoldAsVacant is not null;

-- ----------------------------------------------------------------------------

-- Remove Duplicates
alter table PortfolioProject.nashvillehousingdata
add index idx_uniID(UniqueID);

create temporary table RowNumCTE(UniqueID int);

insert into RowNumCTE(UniqueID)
select UniqueID from
	(select UniqueID,
           row_number() over (
               partition by ParcelID,
							PropertyAddress,
                            SalePrice,
                            SaleDate,
                            LegalReference
							order by UniqueID
           ) as row_num
           from PortfolioProject.nashvillehousingdata
           ) RowNumSubQuery
		where row_num > 1;

delete from PortfolioProject.nashvillehousingdata
where UniqueID in (select UniqueID from RowNumCTE);

drop table if exists RowNumCTE;

-- ----------------------------------------------------------------------------

-- Delete Unused Columns
select *
from PortfolioProject.nashvillehousingdata;

alter table PortfolioProject.nashvillehousingdata
drop column PropertyAddress,
drop column OwnerAddress,
drop column TaxDistrict;



