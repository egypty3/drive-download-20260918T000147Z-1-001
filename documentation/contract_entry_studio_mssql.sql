/* ============================================================================
   TAS AVIATION PORTAL — CONTRACT ENTRY & LIFECYCLE STUDIO
   Microsoft SQL Server Database Creation, Constraints, Seed & Workflow Script
   ----------------------------------------------------------------------------
   Target Engine : Microsoft SQL Server 2019 / 2022 / Azure SQL Database
   Database Name : [TasContractStudioDB]
   Source App    : contract_entry_studio.html
   Architecture  : 26 Normalized Tables · 42 Enforced Foreign Keys · 5 Functional Domains
   Seed Dataset  : 363 Master Lookup, Aircraft Registration, Contract & Lifecycle Rows
   ============================================================================ */

-- ============================================================================
-- SECTION 1: DATABASE CREATION & SESSION CONFIGURATION
-- ============================================================================
USE [master];
GO

IF DB_ID(N'TasContractStudioDB') IS NULL
BEGIN
    CREATE DATABASE [TasContractStudioDB];
END;
GO

ALTER DATABASE [TasContractStudioDB] SET READ_COMMITTED_SNAPSHOT ON;
GO

USE [TasContractStudioDB];
GO

SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
GO

-- ============================================================================
-- SECTION 2: IDEMPOTENT CLEANUP (Dependency-Safe Drop Order)
-- ============================================================================
IF OBJECT_ID(N'dbo.[usp_SaveContractRenewal]', N'P') IS NOT NULL
    DROP PROCEDURE dbo.[usp_SaveContractRenewal];
IF OBJECT_ID(N'dbo.[usp_ApproveAndActivateContract]', N'P') IS NOT NULL
    DROP PROCEDURE dbo.[usp_ApproveAndActivateContract];
GO

IF OBJECT_ID(N'dbo.[vw_ContractQuickAuditCard]', N'V') IS NOT NULL
    DROP VIEW dbo.[vw_ContractQuickAuditCard];
IF OBJECT_ID(N'dbo.[vw_ContractsRegistrySummary]', N'V') IS NOT NULL
    DROP VIEW dbo.[vw_ContractsRegistrySummary];
GO

IF OBJECT_ID(N'dbo.[Sec_ContractAuditLog]', N'U') IS NOT NULL DROP TABLE dbo.[Sec_ContractAuditLog];
IF OBJECT_ID(N'dbo.[Com_AmendmentServices]', N'U') IS NOT NULL DROP TABLE dbo.[Com_AmendmentServices];
IF OBJECT_ID(N'dbo.[Com_AmendmentFleetModels]', N'U') IS NOT NULL DROP TABLE dbo.[Com_AmendmentFleetModels];
IF OBJECT_ID(N'dbo.[Com_AmendmentStations]', N'U') IS NOT NULL DROP TABLE dbo.[Com_AmendmentStations];
IF OBJECT_ID(N'dbo.[Com_AmendmentAmenities]', N'U') IS NOT NULL DROP TABLE dbo.[Com_AmendmentAmenities];
IF OBJECT_ID(N'dbo.[Com_ContractAmendments]', N'U') IS NOT NULL DROP TABLE dbo.[Com_ContractAmendments];
IF OBJECT_ID(N'dbo.[Com_ContractRenewals]', N'U') IS NOT NULL DROP TABLE dbo.[Com_ContractRenewals];
IF OBJECT_ID(N'dbo.[Com_ContractVersions]', N'U') IS NOT NULL DROP TABLE dbo.[Com_ContractVersions];
IF OBJECT_ID(N'dbo.[Com_ContractServices]', N'U') IS NOT NULL DROP TABLE dbo.[Com_ContractServices];
IF OBJECT_ID(N'dbo.[Com_ContractRegistrations]', N'U') IS NOT NULL DROP TABLE dbo.[Com_ContractRegistrations];
IF OBJECT_ID(N'dbo.[Com_ContractFleetModels]', N'U') IS NOT NULL DROP TABLE dbo.[Com_ContractFleetModels];
IF OBJECT_ID(N'dbo.[Com_ContractStations]', N'U') IS NOT NULL DROP TABLE dbo.[Com_ContractStations];
IF OBJECT_ID(N'dbo.[Com_Contracts]', N'U') IS NOT NULL DROP TABLE dbo.[Com_Contracts];
IF OBJECT_ID(N'dbo.[Lkp_GroundServices]', N'U') IS NOT NULL DROP TABLE dbo.[Lkp_GroundServices];
IF OBJECT_ID(N'dbo.[Flt_AircraftRegistrations]', N'U') IS NOT NULL DROP TABLE dbo.[Flt_AircraftRegistrations];
IF OBJECT_ID(N'dbo.[Ar_AirlineCustomers]', N'U') IS NOT NULL DROP TABLE dbo.[Ar_AirlineCustomers];
IF OBJECT_ID(N'dbo.[Lkp_AircraftModels]', N'U') IS NOT NULL DROP TABLE dbo.[Lkp_AircraftModels];
IF OBJECT_ID(N'dbo.[Lkp_MtowTiers]', N'U') IS NOT NULL DROP TABLE dbo.[Lkp_MtowTiers];
IF OBJECT_ID(N'dbo.[Lkp_ApronPolicies]', N'U') IS NOT NULL DROP TABLE dbo.[Lkp_ApronPolicies];
IF OBJECT_ID(N'dbo.[Lkp_AirportStations]', N'U') IS NOT NULL DROP TABLE dbo.[Lkp_AirportStations];
IF OBJECT_ID(N'dbo.[Lkp_CarrierCategories]', N'U') IS NOT NULL DROP TABLE dbo.[Lkp_CarrierCategories];
IF OBJECT_ID(N'dbo.[Lkp_SghaStandards]', N'U') IS NOT NULL DROP TABLE dbo.[Lkp_SghaStandards];
IF OBJECT_ID(N'dbo.[Lkp_PaymentTerms]', N'U') IS NOT NULL DROP TABLE dbo.[Lkp_PaymentTerms];
IF OBJECT_ID(N'dbo.[Lkp_Currencies]', N'U') IS NOT NULL DROP TABLE dbo.[Lkp_Currencies];
IF OBJECT_ID(N'dbo.[Sec_Users]', N'U') IS NOT NULL DROP TABLE dbo.[Sec_Users];
IF OBJECT_ID(N'dbo.[Sec_Roles]', N'U') IS NOT NULL DROP TABLE dbo.[Sec_Roles];
GO

-- ============================================================================
-- SECTION 3: RELATIONAL TABLES, PRIMARY KEYS, CHECKS & FOREIGN KEYS (26 Tables)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Table 1 of 26: dbo.[Sec_Roles]  (5. Roles, Users & Approval Audit)
-- ----------------------------------------------------------------------------
-- Portal role definitions powering the Role Switcher (Commercial Desk draft creator vs Commercial Admin approver).
CREATE TABLE dbo.[Sec_Roles] (
    [RoleCode] NVARCHAR(30) NOT NULL,
    [RoleDisplayName] NVARCHAR(100) NOT NULL,
    [RoleBadgeLabel] NVARCHAR(60) NOT NULL,
    [CanCreateDraft] BIT NOT NULL CONSTRAINT [DF_Sec_Roles_CanCreateDraft] DEFAULT (1),
    [CanEditLatestVersion] BIT NOT NULL CONSTRAINT [DF_Sec_Roles_CanEditLatestVersion] DEFAULT (1),
    [CanApproveAndActivate] BIT NOT NULL CONSTRAINT [DF_Sec_Roles_CanApproveAndActivate] DEFAULT (0),
    [CanExecuteAmendments] BIT NOT NULL CONSTRAINT [DF_Sec_Roles_CanExecuteAmendments] DEFAULT (1),
    [CanManageMasterLookups] BIT NOT NULL CONSTRAINT [DF_Sec_Roles_CanManageMasterLookups] DEFAULT (1),
    [CreatedAt] DATETIME2(0) NOT NULL CONSTRAINT [DF_Sec_Roles_CreatedAt] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_Sec_Roles] PRIMARY KEY CLUSTERED ([RoleCode] ASC),
    CONSTRAINT [CK_Sec_Roles_RoleCode] CHECK ([RoleCode] IN (N'COMMERCIAL_DESK', N'COMMERCIAL_ADMIN'))
);
GO

-- ----------------------------------------------------------------------------
-- Table 2 of 26: dbo.[Sec_Users]  (5. Roles, Users & Approval Audit)
-- ----------------------------------------------------------------------------
-- Authenticated commercial officers and administrators creating, amending, renewing, and approving contracts.
CREATE TABLE dbo.[Sec_Users] (
    [UserID] INT IDENTITY(1,1) NOT NULL,
    [Username] NVARCHAR(60) NOT NULL,
    [FullName] NVARCHAR(120) NOT NULL,
    [AvatarInitials] NVARCHAR(6) NOT NULL,
    [Email] NVARCHAR(150) NOT NULL,
    [RoleCode] NVARCHAR(30) NOT NULL,
    [Department] NVARCHAR(100) NULL,
    [IsActive] BIT NOT NULL CONSTRAINT [DF_Sec_Users_IsActive] DEFAULT (1),
    [CreatedAt] DATETIME2(0) NOT NULL CONSTRAINT [DF_Sec_Users_CreatedAt] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_Sec_Users] PRIMARY KEY CLUSTERED ([UserID] ASC),
    CONSTRAINT [UQ_Sec_Users_Username] UNIQUE NONCLUSTERED ([Username] ASC),
    CONSTRAINT [UQ_Sec_Users_Email] UNIQUE NONCLUSTERED ([Email] ASC),
    CONSTRAINT [FK_Sec_Users_Sec_Roles] FOREIGN KEY ([RoleCode]) REFERENCES dbo.[Sec_Roles] ([RoleCode])
);
GO

-- ----------------------------------------------------------------------------
-- Table 3 of 26: dbo.[Lkp_Currencies]  (1. Financial, Legal Standards & Airline Customers)
-- ----------------------------------------------------------------------------
-- Master Lookup #6 — ISO 4217 billing currencies, symbols, USD conversion rates, and base currency flags (Step 1 & Master Lookups).
CREATE TABLE dbo.[Lkp_Currencies] (
    [CurrencyCode] NVARCHAR(10) NOT NULL,
    [CurrencySymbol] NVARCHAR(10) NOT NULL,
    [CurrencyName] NVARCHAR(100) NOT NULL,
    [ExchangeRateToUSD] DECIMAL(18, 6) NOT NULL,
    [IsBaseCurrency] BIT NOT NULL CONSTRAINT [DF_Lkp_Currencies_IsBaseCurrency] DEFAULT (0),
    [DisplayFormat] NVARCHAR(120) NOT NULL,
    [IsActive] BIT NOT NULL CONSTRAINT [DF_Lkp_Currencies_IsActive] DEFAULT (1),
    [CreatedAt] DATETIME2(0) NOT NULL CONSTRAINT [DF_Lkp_Currencies_CreatedAt] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_Lkp_Currencies] PRIMARY KEY CLUSTERED ([CurrencyCode] ASC),
    CONSTRAINT [CK_Lkp_Currencies_PositiveRate] CHECK ([ExchangeRateToUSD] > (0))
);
GO

-- ----------------------------------------------------------------------------
-- Table 4 of 26: dbo.[Lkp_PaymentTerms]  (1. Financial, Legal Standards & Airline Customers)
-- ----------------------------------------------------------------------------
-- Master Lookup #7 — Payment & credit settlement terms (Net 30, Net 14, 100% Proforma, Net 60, Net 45, Net 7) and credit risk tiers.
CREATE TABLE dbo.[Lkp_PaymentTerms] (
    [PaymentTermCode] NVARCHAR(20) NOT NULL,
    [TermName] NVARCHAR(120) NOT NULL,
    [CreditSettlementDays] INT NOT NULL,
    [CreditRiskCategory] NVARCHAR(60) NOT NULL,
    [BillingCycleDesc] NVARCHAR(300) NULL,
    [IsActive] BIT NOT NULL CONSTRAINT [DF_Lkp_PaymentTerms_IsActive] DEFAULT (1),
    [CreatedAt] DATETIME2(0) NOT NULL CONSTRAINT [DF_Lkp_PaymentTerms_CreatedAt] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_Lkp_PaymentTerms] PRIMARY KEY CLUSTERED ([PaymentTermCode] ASC),
    CONSTRAINT [CK_Lkp_PaymentTerms_Days] CHECK ([CreditSettlementDays] BETWEEN (0) AND (365))
);
GO

-- ----------------------------------------------------------------------------
-- Table 5 of 26: dbo.[Lkp_SghaStandards]  (1. Financial, Legal Standards & Airline Customers)
-- ----------------------------------------------------------------------------
-- Master Lookup #8 — IATA Standard Ground Handling Agreement (SGHA) editions and custom bilateral SLA frameworks.
CREATE TABLE dbo.[Lkp_SghaStandards] (
    [SghaStandardCode] NVARCHAR(30) NOT NULL,
    [EditionRelease] NVARCHAR(30) NOT NULL,
    [StandardFullName] NVARCHAR(150) NOT NULL,
    [GoverningBody] NVARCHAR(100) NULL,
    [StandardDescription] NVARCHAR(400) NULL,
    [IsActive] BIT NOT NULL CONSTRAINT [DF_Lkp_SghaStandards_IsActive] DEFAULT (1),
    [CreatedAt] DATETIME2(0) NOT NULL CONSTRAINT [DF_Lkp_SghaStandards_CreatedAt] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_Lkp_SghaStandards] PRIMARY KEY CLUSTERED ([SghaStandardCode] ASC)
);
GO

-- ----------------------------------------------------------------------------
-- Table 6 of 26: dbo.[Lkp_CarrierCategories]  (1. Financial, Legal Standards & Airline Customers)
-- ----------------------------------------------------------------------------
-- Airline operating classifications used in Contracts Registry filtering & Airline Customer setup (Commercial, Charter, Cargo, LCC, VIP).
CREATE TABLE dbo.[Lkp_CarrierCategories] (
    [CategoryCode] NVARCHAR(20) NOT NULL,
    [CategoryName] NVARCHAR(80) NOT NULL,
    [DefaultTargetMarginPct] DECIMAL(5, 2) NOT NULL,
    [SortOrder] INT NOT NULL,
    [IsActive] BIT NOT NULL CONSTRAINT [DF_Lkp_CarrierCategories_IsActive] DEFAULT (1),
    CONSTRAINT [PK_Lkp_CarrierCategories] PRIMARY KEY CLUSTERED ([CategoryCode] ASC)
);
GO

-- ----------------------------------------------------------------------------
-- Table 7 of 26: dbo.[Lkp_AirportStations]  (4. Airport Stations, Fleet, Registrations & Ground Services)
-- ----------------------------------------------------------------------------
-- Master Lookup #2 — Authorized Egyptian airport stations (CAI, HRG, SSH, LXR, HBE, SPX, etc.) and regional hubs (Step 2).
CREATE TABLE dbo.[Lkp_AirportStations] (
    [StationCode] NVARCHAR(10) NOT NULL,
    [AirportName] NVARCHAR(150) NOT NULL,
    [RegionGovernorate] NVARCHAR(100) NULL,
    [CountryName] NVARCHAR(80) NOT NULL CONSTRAINT [DF_Lkp_AirportStations_CountryName] DEFAULT N'Egypt',
    [IsPrimaryHubEligible] BIT NOT NULL CONSTRAINT [DF_Lkp_AirportStations_IsPrimaryHubEligible] DEFAULT (1),
    [IsActive] BIT NOT NULL CONSTRAINT [DF_Lkp_AirportStations_IsActive] DEFAULT (1),
    [CreatedAt] DATETIME2(0) NOT NULL CONSTRAINT [DF_Lkp_AirportStations_CreatedAt] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_Lkp_AirportStations] PRIMARY KEY CLUSTERED ([StationCode] ASC)
);
GO

-- ----------------------------------------------------------------------------
-- Table 8 of 26: dbo.[Lkp_ApronPolicies]  (4. Airport Stations, Fleet, Registrations & Ground Services)
-- ----------------------------------------------------------------------------
-- Master Lookup #9 — Apron stand parking & passenger boarding transfer policies (Contact Gate, Remote Cobus, Walk-in, VIP, Cargo Ramp).
CREATE TABLE dbo.[Lkp_ApronPolicies] (
    [ApronPolicyCode] NVARCHAR(30) NOT NULL,
    [PolicyName] NVARCHAR(150) NOT NULL,
    [StandCategory] NVARCHAR(60) NOT NULL,
    [TransferBoardingMethod] NVARCHAR(120) NULL,
    [OperationalSlaNotes] NVARCHAR(400) NULL,
    [IsActive] BIT NOT NULL CONSTRAINT [DF_Lkp_ApronPolicies_IsActive] DEFAULT (1),
    [CreatedAt] DATETIME2(0) NOT NULL CONSTRAINT [DF_Lkp_ApronPolicies_CreatedAt] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_Lkp_ApronPolicies] PRIMARY KEY CLUSTERED ([ApronPolicyCode] ASC)
);
GO

-- ----------------------------------------------------------------------------
-- Table 9 of 26: dbo.[Lkp_MtowTiers]  (4. Airport Stations, Fleet, Registrations & Ground Services)
-- ----------------------------------------------------------------------------
-- Maximum Takeoff Weight (MTOW) billing categories (Narrowbody, Widebody, Heavy >250T, Regional Turboprop <50T) in Step 3.
CREATE TABLE dbo.[Lkp_MtowTiers] (
    [MtowTierCode] NVARCHAR(20) NOT NULL,
    [TierDisplayName] NVARCHAR(100) NOT NULL,
    [MinWeightTons] DECIMAL(8, 2) NOT NULL,
    [MaxWeightTons] DECIMAL(8, 2) NULL,
    [SortOrder] INT NOT NULL,
    CONSTRAINT [PK_Lkp_MtowTiers] PRIMARY KEY CLUSTERED ([MtowTierCode] ASC)
);
GO

-- ----------------------------------------------------------------------------
-- Table 10 of 26: dbo.[Lkp_AircraftModels]  (4. Airport Stations, Fleet, Registrations & Ground Services)
-- ----------------------------------------------------------------------------
-- Master Lookup #3 — Aircraft airframe models (A320, A321, B738, B77W, B789, A332F, etc.) mapped to MTOW weight tiers (Step 3).
CREATE TABLE dbo.[Lkp_AircraftModels] (
    [ModelCode] NVARCHAR(20) NOT NULL,
    [ManufacturerDesc] NVARCHAR(150) NOT NULL,
    [MtowTierCode] NVARCHAR(20) NOT NULL,
    [IsCargoFreighter] BIT NOT NULL CONSTRAINT [DF_Lkp_AircraftModels_IsCargoFreighter] DEFAULT (0),
    [DefaultTurnaroundMins] INT NOT NULL CONSTRAINT [DF_Lkp_AircraftModels_DefaultTurnaroundMins] DEFAULT (45),
    [IsActive] BIT NOT NULL CONSTRAINT [DF_Lkp_AircraftModels_IsActive] DEFAULT (1),
    [CreatedAt] DATETIME2(0) NOT NULL CONSTRAINT [DF_Lkp_AircraftModels_CreatedAt] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_Lkp_AircraftModels] PRIMARY KEY CLUSTERED ([ModelCode] ASC),
    CONSTRAINT [FK_Lkp_AircraftModels_MtowTiers] FOREIGN KEY ([MtowTierCode]) REFERENCES dbo.[Lkp_MtowTiers] ([MtowTierCode])
);
GO

-- ----------------------------------------------------------------------------
-- Table 11 of 26: dbo.[Ar_AirlineCustomers]  (1. Financial, Legal Standards & Airline Customers)
-- ----------------------------------------------------------------------------
-- Master Lookup #1 — Corporate airline & carrier accounts with IATA/ICAO codes, default credit terms, currency, and hub station.
CREATE TABLE dbo.[Ar_AirlineCustomers] (
    [CustomerID] NVARCHAR(40) NOT NULL,
    [CarrierDisplayCode] NVARCHAR(25) NOT NULL,
    [IataCode] NVARCHAR(10) NOT NULL,
    [IcaoCode] NVARCHAR(10) NULL,
    [CustomerFullName] NVARCHAR(200) NOT NULL,
    [CategoryCode] NVARCHAR(20) NOT NULL,
    [DefaultPaymentTermCode] NVARCHAR(20) NOT NULL,
    [DefaultCurrencyCode] NVARCHAR(10) NOT NULL CONSTRAINT [DF_Ar_AirlineCustomers_DefaultCurrencyCode] DEFAULT N'USD',
    [PrimaryHubStationCode] NVARCHAR(10) NULL,
    [CountryRegion] NVARCHAR(100) NULL,
    [IsActive] BIT NOT NULL CONSTRAINT [DF_Ar_AirlineCustomers_IsActive] DEFAULT (1),
    [CreatedAt] DATETIME2(0) NOT NULL CONSTRAINT [DF_Ar_AirlineCustomers_CreatedAt] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_Ar_AirlineCustomers] PRIMARY KEY CLUSTERED ([CustomerID] ASC),
    CONSTRAINT [FK_Ar_AirlineCustomers_Categories] FOREIGN KEY ([CategoryCode]) REFERENCES dbo.[Lkp_CarrierCategories] ([CategoryCode]),
    CONSTRAINT [FK_Ar_AirlineCustomers_PaymentTerms] FOREIGN KEY ([DefaultPaymentTermCode]) REFERENCES dbo.[Lkp_PaymentTerms] ([PaymentTermCode]),
    CONSTRAINT [FK_Ar_AirlineCustomers_Currencies] FOREIGN KEY ([DefaultCurrencyCode]) REFERENCES dbo.[Lkp_Currencies] ([CurrencyCode]),
    CONSTRAINT [FK_Ar_AirlineCustomers_HubStation] FOREIGN KEY ([PrimaryHubStationCode]) REFERENCES dbo.[Lkp_AirportStations] ([StationCode])
);
GO

-- ----------------------------------------------------------------------------
-- Table 12 of 26: dbo.[Flt_AircraftRegistrations]  (4. Airport Stations, Fleet, Registrations & Ground Services)
-- ----------------------------------------------------------------------------
-- Master Lookup #4 — Individual aircraft registrations (e.g. SU-GBF, OK-TVF), certified MTOW tons, seat capacity, and ownership/lease status.
CREATE TABLE dbo.[Flt_AircraftRegistrations] (
    [RegistrationNo] NVARCHAR(20) NOT NULL,
    [CustomerID] NVARCHAR(40) NOT NULL,
    [ModelCode] NVARCHAR(20) NOT NULL,
    [OperatingCarrierCode] NVARCHAR(25) NOT NULL,
    [VariantModelName] NVARCHAR(120) NULL,
    [CertifiedMtowTons] DECIMAL(8, 2) NOT NULL,
    [PassengerSeats] INT NOT NULL CONSTRAINT [DF_Flt_AircraftRegistrations_PassengerSeats] DEFAULT (0),
    [OwnershipStatus] NVARCHAR(20) NOT NULL CONSTRAINT [DF_Flt_AircraftRegistrations_OwnershipStatus] DEFAULT N'OWNED',
    [IsLeased] BIT NOT NULL CONSTRAINT [DF_Flt_AircraftRegistrations_IsLeased] DEFAULT (0),
    [OperationalStatus] NVARCHAR(30) NOT NULL CONSTRAINT [DF_Flt_AircraftRegistrations_OperationalStatus] DEFAULT N'Active',
    [CreatedAt] DATETIME2(0) NOT NULL CONSTRAINT [DF_Flt_AircraftRegistrations_CreatedAt] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_Flt_AircraftRegistrations] PRIMARY KEY CLUSTERED ([RegistrationNo] ASC),
    CONSTRAINT [CK_Flt_AircraftRegistrations_Ownership] CHECK ([OwnershipStatus] IN (N'OWNED', N'LEASED_DRY', N'LEASED_WET')),
    CONSTRAINT [CK_Flt_AircraftRegistrations_Mtow] CHECK ([CertifiedMtowTons] > (0)),
    CONSTRAINT [FK_Flt_AircraftRegistrations_Customers] FOREIGN KEY ([CustomerID]) REFERENCES dbo.[Ar_AirlineCustomers] ([CustomerID]),
    CONSTRAINT [FK_Flt_AircraftRegistrations_Models] FOREIGN KEY ([ModelCode]) REFERENCES dbo.[Lkp_AircraftModels] ([ModelCode])
);
GO

-- ----------------------------------------------------------------------------
-- Table 13 of 26: dbo.[Lkp_GroundServices]  (4. Airport Stations, Fleet, Registrations & Ground Services)
-- ----------------------------------------------------------------------------
-- Master Lookup #5 — Ground handling services & auxiliary ramp GSE tariff catalog (GPU, ASU, ACU, Pushback, Lavatory, Potable Water, etc.).
CREATE TABLE dbo.[Lkp_GroundServices] (
    [ServiceCode] NVARCHAR(30) NOT NULL,
    [ServiceName] NVARCHAR(200) NOT NULL,
    [StandardTariffUSD] DECIMAL(12, 2) NOT NULL,
    [BillingUnit] NVARCHAR(30) NOT NULL CONSTRAINT [DF_Lkp_GroundServices_BillingUnit] DEFAULT N'Per Sortie',
    [SghaAnnexSection] NVARCHAR(60) NULL,
    [IconSymbol] NVARCHAR(10) NULL,
    [IsAuxiliaryGse] BIT NOT NULL CONSTRAINT [DF_Lkp_GroundServices_IsAuxiliaryGse] DEFAULT (1),
    [IsActive] BIT NOT NULL CONSTRAINT [DF_Lkp_GroundServices_IsActive] DEFAULT (1),
    [CreatedAt] DATETIME2(0) NOT NULL CONSTRAINT [DF_Lkp_GroundServices_CreatedAt] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_Lkp_GroundServices] PRIMARY KEY CLUSTERED ([ServiceCode] ASC),
    CONSTRAINT [CK_Lkp_GroundServices_Rate] CHECK ([StandardTariffUSD] >= (0))
);
GO

-- ----------------------------------------------------------------------------
-- Table 14 of 26: dbo.[Com_Contracts]  (2. Core Commercial Contracts & Coverage Scope)
-- ----------------------------------------------------------------------------
-- Primary commercial ground handling contract header storing all 5-Step Wizard parameters, validity dates, base tariffs, registration policy, and approval state.
CREATE TABLE dbo.[Com_Contracts] (
    [ContractID] INT IDENTITY(1,1) NOT NULL,
    [ContractRef] NVARCHAR(50) NOT NULL,
    [CustomerReference] NVARCHAR(60) NULL,
    [CustomerID] NVARCHAR(40) NOT NULL,
    [CategoryCode] NVARCHAR(20) NOT NULL,
    [ContractStatus] NVARCHAR(20) NOT NULL CONSTRAINT [DF_Com_Contracts_ContractStatus] DEFAULT N'DRAFT',
    [CurrentVersionLabel] NVARCHAR(30) NOT NULL CONSTRAINT [DF_Com_Contracts_CurrentVersionLabel] DEFAULT N'v1.0',
    [PrimaryStationCode] NVARCHAR(10) NOT NULL,
    [EffectiveFromDate] DATE NOT NULL,
    [ValidToDate] DATE NOT NULL,
    [CurrencyCode] NVARCHAR(10) NOT NULL CONSTRAINT [DF_Com_Contracts_CurrencyCode] DEFAULT N'USD',
    [PaymentTermCode] NVARCHAR(20) NOT NULL,
    [SghaStandardCode] NVARCHAR(30) NOT NULL,
    [ApronPolicyCode] NVARCHAR(30) NOT NULL,
    [MtowTierCode] NVARCHAR(20) NULL,
    [RegistrationScope] NVARCHAR(15) NOT NULL CONSTRAINT [DF_Com_Contracts_RegistrationScope] DEFAULT N'ALL',
    [ConcessionRoyaltyPct] DECIMAL(5, 2) NOT NULL CONSTRAINT [DF_Com_Contracts_ConcessionRoyaltyPct] DEFAULT (12.00),
    [TurnaroundDurationMins] INT NOT NULL CONSTRAINT [DF_Com_Contracts_TurnaroundDurationMins] DEFAULT (45),
    [MonthlyFlightVolume] INT NOT NULL,
    [BaseNarrowRateUSD] DECIMAL(12, 2) NOT NULL,
    [BaseWideRateUSD] DECIMAL(12, 2) NULL,
    [AnnualEscalationPct] DECIMAL(5, 2) NOT NULL CONSTRAINT [DF_Com_Contracts_AnnualEscalationPct] DEFAULT (0.00),
    [EstimatedMonthlyRevUSD] DECIMAL(15, 2) NOT NULL,
    [AnnualContractValueUSD] DECIMAL(15, 2) NOT NULL,
    [ProfitMarginPct] DECIMAL(5, 2) NOT NULL CONSTRAINT [DF_Com_Contracts_ProfitMarginPct] DEFAULT (27.00),
    [CommercialRemarks] NVARCHAR(2000) NULL,
    [CreatedDate] DATE NOT NULL,
    [CreatedByUserID] INT NOT NULL,
    [ApprovedByUserID] INT NULL,
    [ApprovedAt] DATETIME2(0) NULL,
    [UpdatedAt] DATETIME2(0) NOT NULL CONSTRAINT [DF_Com_Contracts_UpdatedAt] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_Com_Contracts] PRIMARY KEY CLUSTERED ([ContractID] ASC),
    CONSTRAINT [UQ_Com_Contracts_ContractRef] UNIQUE NONCLUSTERED ([ContractRef] ASC),
    CONSTRAINT [CK_Com_Contracts_Status] CHECK ([ContractStatus] IN (N'DRAFT', N'PENDING', N'ACTIVE', N'EXPIRING', N'RENEWAL', N'EXPIRED')),
    CONSTRAINT [CK_Com_Contracts_RegScope] CHECK ([RegistrationScope] IN (N'ALL', N'CUSTOM')),
    CONSTRAINT [CK_Com_Contracts_DateOrder] CHECK ([ValidToDate] >= [EffectiveFromDate]),
    CONSTRAINT [FK_Com_Contracts_Customers] FOREIGN KEY ([CustomerID]) REFERENCES dbo.[Ar_AirlineCustomers] ([CustomerID]),
    CONSTRAINT [FK_Com_Contracts_Categories] FOREIGN KEY ([CategoryCode]) REFERENCES dbo.[Lkp_CarrierCategories] ([CategoryCode]),
    CONSTRAINT [FK_Com_Contracts_PrimaryStation] FOREIGN KEY ([PrimaryStationCode]) REFERENCES dbo.[Lkp_AirportStations] ([StationCode]),
    CONSTRAINT [FK_Com_Contracts_Currencies] FOREIGN KEY ([CurrencyCode]) REFERENCES dbo.[Lkp_Currencies] ([CurrencyCode]),
    CONSTRAINT [FK_Com_Contracts_PaymentTerms] FOREIGN KEY ([PaymentTermCode]) REFERENCES dbo.[Lkp_PaymentTerms] ([PaymentTermCode]),
    CONSTRAINT [FK_Com_Contracts_SghaStandards] FOREIGN KEY ([SghaStandardCode]) REFERENCES dbo.[Lkp_SghaStandards] ([SghaStandardCode]),
    CONSTRAINT [FK_Com_Contracts_ApronPolicies] FOREIGN KEY ([ApronPolicyCode]) REFERENCES dbo.[Lkp_ApronPolicies] ([ApronPolicyCode]),
    CONSTRAINT [FK_Com_Contracts_MtowTiers] FOREIGN KEY ([MtowTierCode]) REFERENCES dbo.[Lkp_MtowTiers] ([MtowTierCode]),
    CONSTRAINT [FK_Com_Contracts_CreatedByUser] FOREIGN KEY ([CreatedByUserID]) REFERENCES dbo.[Sec_Users] ([UserID]),
    CONSTRAINT [FK_Com_Contracts_ApprovedByUser] FOREIGN KEY ([ApprovedByUserID]) REFERENCES dbo.[Sec_Users] ([UserID])
);
GO

-- ----------------------------------------------------------------------------
-- Table 15 of 26: dbo.[Com_ContractStations]  (2. Core Commercial Contracts & Coverage Scope)
-- ----------------------------------------------------------------------------
-- Step 2 M:N junction — Authorized airport stations network for each contract, flagging the Primary Hub and whether added via base entry or amendment.
CREATE TABLE dbo.[Com_ContractStations] (
    [ContractID] INT NOT NULL,
    [StationCode] NVARCHAR(10) NOT NULL,
    [IsPrimaryHub] BIT NOT NULL CONSTRAINT [DF_Com_ContractStations_IsPrimaryHub] DEFAULT (0),
    [SourceType] NVARCHAR(20) NOT NULL CONSTRAINT [DF_Com_ContractStations_SourceType] DEFAULT N'BASE',
    [AuthorizedAt] DATETIME2(0) NOT NULL CONSTRAINT [DF_Com_ContractStations_AuthorizedAt] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_Com_ContractStations] PRIMARY KEY CLUSTERED ([ContractID] ASC, [StationCode] ASC),
    CONSTRAINT [CK_Com_ContractStations_Source] CHECK ([SourceType] IN (N'BASE', N'AMENDMENT')),
    CONSTRAINT [FK_Com_ContractStations_Contracts] FOREIGN KEY ([ContractID]) REFERENCES dbo.[Com_Contracts] ([ContractID]) ON DELETE CASCADE,
    CONSTRAINT [FK_Com_ContractStations_Stations] FOREIGN KEY ([StationCode]) REFERENCES dbo.[Lkp_AirportStations] ([StationCode])
);
GO

-- ----------------------------------------------------------------------------
-- Table 16 of 26: dbo.[Com_ContractFleetModels]  (2. Core Commercial Contracts & Coverage Scope)
-- ----------------------------------------------------------------------------
-- Step 3 M:N junction — Covered aircraft types and models authorized under each ground handling contract.
CREATE TABLE dbo.[Com_ContractFleetModels] (
    [ContractID] INT NOT NULL,
    [ModelCode] NVARCHAR(20) NOT NULL,
    [SourceType] NVARCHAR(20) NOT NULL CONSTRAINT [DF_Com_ContractFleetModels_SourceType] DEFAULT N'BASE',
    [AuthorizedAt] DATETIME2(0) NOT NULL CONSTRAINT [DF_Com_ContractFleetModels_AuthorizedAt] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_Com_ContractFleetModels] PRIMARY KEY CLUSTERED ([ContractID] ASC, [ModelCode] ASC),
    CONSTRAINT [CK_Com_ContractFleetModels_Source] CHECK ([SourceType] IN (N'BASE', N'AMENDMENT')),
    CONSTRAINT [FK_Com_ContractFleetModels_Contracts] FOREIGN KEY ([ContractID]) REFERENCES dbo.[Com_Contracts] ([ContractID]) ON DELETE CASCADE,
    CONSTRAINT [FK_Com_ContractFleetModels_Models] FOREIGN KEY ([ModelCode]) REFERENCES dbo.[Lkp_AircraftModels] ([ModelCode])
);
GO

-- ----------------------------------------------------------------------------
-- Table 17 of 26: dbo.[Com_ContractRegistrations]  (2. Core Commercial Contracts & Coverage Scope)
-- ----------------------------------------------------------------------------
-- Step 3 M:N junction — Specific Aircraft Registration Whitelist locking turnaround work orders to designated aircraft registrations when RegistrationScope = CUSTOM.
CREATE TABLE dbo.[Com_ContractRegistrations] (
    [ContractID] INT NOT NULL,
    [RegistrationNo] NVARCHAR(20) NOT NULL,
    [WhitelistedAt] DATETIME2(0) NOT NULL CONSTRAINT [DF_Com_ContractRegistrations_WhitelistedAt] DEFAULT SYSUTCDATETIME(),
    [RegistrationNotes] NVARCHAR(250) NULL,
    CONSTRAINT [PK_Com_ContractRegistrations] PRIMARY KEY CLUSTERED ([ContractID] ASC, [RegistrationNo] ASC),
    CONSTRAINT [FK_Com_ContractRegistrations_Contracts] FOREIGN KEY ([ContractID]) REFERENCES dbo.[Com_Contracts] ([ContractID]) ON DELETE CASCADE,
    CONSTRAINT [FK_Com_ContractRegistrations_Registrations] FOREIGN KEY ([RegistrationNo]) REFERENCES dbo.[Flt_AircraftRegistrations] ([RegistrationNo])
);
GO

-- ----------------------------------------------------------------------------
-- Table 18 of 26: dbo.[Com_ContractServices]  (2. Core Commercial Contracts & Coverage Scope)
-- ----------------------------------------------------------------------------
-- Step 4 & Step 5 SLA Review M:N junction — Contracted ground handling services & auxiliary GSE items with negotiated sortie rates and monthly commitment.
CREATE TABLE dbo.[Com_ContractServices] (
    [ContractID] INT NOT NULL,
    [ServiceCode] NVARCHAR(30) NOT NULL,
    [NegotiatedRateUSD] DECIMAL(12, 2) NOT NULL,
    [EstMonthlyCommitmentUSD] DECIMAL(14, 2) NOT NULL,
    [IsIncludedInSla] BIT NOT NULL CONSTRAINT [DF_Com_ContractServices_IsIncludedInSla] DEFAULT (1),
    [SourceType] NVARCHAR(20) NOT NULL CONSTRAINT [DF_Com_ContractServices_SourceType] DEFAULT N'BASE',
    CONSTRAINT [PK_Com_ContractServices] PRIMARY KEY CLUSTERED ([ContractID] ASC, [ServiceCode] ASC),
    CONSTRAINT [FK_Com_ContractServices_Contracts] FOREIGN KEY ([ContractID]) REFERENCES dbo.[Com_Contracts] ([ContractID]) ON DELETE CASCADE,
    CONSTRAINT [FK_Com_ContractServices_Services] FOREIGN KEY ([ServiceCode]) REFERENCES dbo.[Lkp_GroundServices] ([ServiceCode])
);
GO

-- ----------------------------------------------------------------------------
-- Table 19 of 26: dbo.[Com_ContractVersions]  (3. Versioning, Renewals & Operational Amendments)
-- ----------------------------------------------------------------------------
-- Contract Version History backing the Registry table version dropdown (Ver: v1.0, v1.1 AMD, v2.0 Renewed) and read-only lock on archived releases.
CREATE TABLE dbo.[Com_ContractVersions] (
    [ContractVersionID] INT IDENTITY(1,1) NOT NULL,
    [ContractID] INT NOT NULL,
    [VersionLabel] NVARCHAR(30) NOT NULL,
    [VersionStatus] NVARCHAR(20) NOT NULL,
    [VersionDate] DATE NOT NULL,
    [IsLatestVersion] BIT NOT NULL CONSTRAINT [DF_Com_ContractVersions_IsLatestVersion] DEFAULT (1),
    [IsLockedArchive] BIT NOT NULL CONSTRAINT [DF_Com_ContractVersions_IsLockedArchive] DEFAULT (0),
    [AnnualValueSnapshotUSD] DECIMAL(15, 2) NOT NULL,
    [VersionNotes] NVARCHAR(500) NULL,
    [CreatedByUserID] INT NOT NULL,
    [CreatedAt] DATETIME2(0) NOT NULL CONSTRAINT [DF_Com_ContractVersions_CreatedAt] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_Com_ContractVersions] PRIMARY KEY CLUSTERED ([ContractVersionID] ASC),
    CONSTRAINT [CK_Com_ContractVersions_Status] CHECK ([VersionStatus] IN (N'DRAFT', N'PENDING', N'ACTIVE', N'EXPIRING', N'RENEWAL', N'EXPIRED', N'SUPERSEDED')),
    CONSTRAINT [FK_Com_ContractVersions_Contracts] FOREIGN KEY ([ContractID]) REFERENCES dbo.[Com_Contracts] ([ContractID]) ON DELETE CASCADE,
    CONSTRAINT [FK_Com_ContractVersions_Users] FOREIGN KEY ([CreatedByUserID]) REFERENCES dbo.[Sec_Users] ([UserID])
);
GO

-- ----------------------------------------------------------------------------
-- Table 20 of 26: dbo.[Com_ContractRenewals]  (3. Versioning, Renewals & Operational Amendments)
-- ----------------------------------------------------------------------------
-- Contract Renewal Dialog records storing duration presets (+1/+2/+3 yrs), inflation indexation %, generated -R1/-R2 refs, and updated annual values.
CREATE TABLE dbo.[Com_ContractRenewals] (
    [RenewalID] INT IDENTITY(1,1) NOT NULL,
    [ContractID] INT NOT NULL,
    [PreviousContractRef] NVARCHAR(50) NOT NULL,
    [GeneratedRenewalRef] NVARCHAR(50) NOT NULL,
    [PreviousStartDate] DATE NOT NULL,
    [PreviousEndDate] DATE NOT NULL,
    [NewEffectiveDate] DATE NOT NULL,
    [NewExpiryDate] DATE NOT NULL,
    [ExtensionDurationYears] INT NULL,
    [InflationIndexationPct] DECIMAL(5, 2) NOT NULL CONSTRAINT [DF_Com_ContractRenewals_InflationIndexationPct] DEFAULT (0.00),
    [PreviousAnnualValueUSD] DECIMAL(15, 2) NOT NULL,
    [UpdatedAnnualValueUSD] DECIMAL(15, 2) NOT NULL,
    [ExecutionMode] NVARCHAR(20) NOT NULL CONSTRAINT [DF_Com_ContractRenewals_ExecutionMode] DEFAULT N'DIRECT_APPLY',
    [RenewalAddendumNotes] NVARCHAR(500) NULL,
    [RenewedByUserID] INT NOT NULL,
    [RenewedAt] DATETIME2(0) NOT NULL CONSTRAINT [DF_Com_ContractRenewals_RenewedAt] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_Com_ContractRenewals] PRIMARY KEY CLUSTERED ([RenewalID] ASC),
    CONSTRAINT [CK_Com_ContractRenewals_Dates] CHECK ([NewExpiryDate] > [NewEffectiveDate]),
    CONSTRAINT [FK_Com_ContractRenewals_Contracts] FOREIGN KEY ([ContractID]) REFERENCES dbo.[Com_Contracts] ([ContractID]) ON DELETE CASCADE,
    CONSTRAINT [FK_Com_ContractRenewals_Users] FOREIGN KEY ([RenewedByUserID]) REFERENCES dbo.[Sec_Users] ([UserID])
);
GO

-- ----------------------------------------------------------------------------
-- Table 21 of 26: dbo.[Com_ContractAmendments]  (3. Versioning, Renewals & Operational Amendments)
-- ----------------------------------------------------------------------------
-- Contract Amendment & Options Header storing executed addenda (-AMD-1, -AMD-2), effective dates, monthly surcharge USD, and resulting annual contract value.
CREATE TABLE dbo.[Com_ContractAmendments] (
    [AmendmentID] INT IDENTITY(1,1) NOT NULL,
    [ContractID] INT NOT NULL,
    [AmendmentRef] NVARCHAR(60) NOT NULL,
    [AmendmentTitle] NVARCHAR(200) NOT NULL,
    [EffectiveDate] DATE NOT NULL,
    [CreatedDate] DATE NOT NULL,
    [MonthlySurchargeUSD] DECIMAL(12, 2) NOT NULL CONSTRAINT [DF_Com_ContractAmendments_MonthlySurchargeUSD] DEFAULT (0.00),
    [PreviousAnnualValueUSD] DECIMAL(15, 2) NOT NULL,
    [UpdatedAnnualValueUSD] DECIMAL(15, 2) NOT NULL,
    [ResultingVersionLabel] NVARCHAR(30) NOT NULL,
    [ClauseNotes] NVARCHAR(1000) NULL,
    [CreatedByUserID] INT NOT NULL,
    [CreatedAt] DATETIME2(0) NOT NULL CONSTRAINT [DF_Com_ContractAmendments_CreatedAt] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_Com_ContractAmendments] PRIMARY KEY CLUSTERED ([AmendmentID] ASC),
    CONSTRAINT [UQ_Com_ContractAmendments_AmendmentRef] UNIQUE NONCLUSTERED ([AmendmentRef] ASC),
    CONSTRAINT [FK_Com_ContractAmendments_Contracts] FOREIGN KEY ([ContractID]) REFERENCES dbo.[Com_Contracts] ([ContractID]) ON DELETE CASCADE,
    CONSTRAINT [FK_Com_ContractAmendments_Users] FOREIGN KEY ([CreatedByUserID]) REFERENCES dbo.[Sec_Users] ([UserID])
);
GO

-- ----------------------------------------------------------------------------
-- Table 22 of 26: dbo.[Com_AmendmentAmenities]  (3. Versioning, Renewals & Operational Amendments)
-- ----------------------------------------------------------------------------
-- 1:1 Amendment Operational Amenities — Crew Housing (hotel tier, board, rooms, station), Crew Transport, Passenger Stairs & Ladders, and Potable Drinking Water.
CREATE TABLE dbo.[Com_AmendmentAmenities] (
    [AmendmentID] INT NOT NULL,
    [CrewHousingEnabled] BIT NOT NULL CONSTRAINT [DF_Com_AmendmentAmenities_CrewHousingEnabled] DEFAULT (0),
    [HousingHotelTier] NVARCHAR(80) NULL,
    [HousingBoardType] NVARCHAR(40) NULL,
    [HousingRoomsAllocated] INT NULL,
    [HousingStationCode] NVARCHAR(10) NULL,
    [CrewTransportEnabled] BIT NOT NULL CONSTRAINT [DF_Com_AmendmentAmenities_CrewTransportEnabled] DEFAULT (0),
    [TransportVehicleType] NVARCHAR(100) NULL,
    [TransportRouteType] NVARCHAR(120) NULL,
    [PassengerLaddersEnabled] BIT NOT NULL CONSTRAINT [DF_Com_AmendmentAmenities_PassengerLaddersEnabled] DEFAULT (0),
    [LadderSpecification] NVARCHAR(120) NULL,
    [StairOperatorIncluded] BIT NOT NULL CONSTRAINT [DF_Com_AmendmentAmenities_StairOperatorIncluded] DEFAULT (1),
    [StairLightingIncluded] BIT NOT NULL CONSTRAINT [DF_Com_AmendmentAmenities_StairLightingIncluded] DEFAULT (1),
    [PotableWaterEnabled] BIT NOT NULL CONSTRAINT [DF_Com_AmendmentAmenities_PotableWaterEnabled] DEFAULT (0),
    [WaterRefillCapacity] NVARCHAR(100) NULL,
    [WaterWhoCertificate] BIT NOT NULL CONSTRAINT [DF_Com_AmendmentAmenities_WaterWhoCertificate] DEFAULT (1),
    [WaterAntiBacterialFlush] BIT NOT NULL CONSTRAINT [DF_Com_AmendmentAmenities_WaterAntiBacterialFlush] DEFAULT (1),
    CONSTRAINT [PK_Com_AmendmentAmenities] PRIMARY KEY CLUSTERED ([AmendmentID] ASC),
    CONSTRAINT [FK_Com_AmendmentAmenities_Amendments] FOREIGN KEY ([AmendmentID]) REFERENCES dbo.[Com_ContractAmendments] ([AmendmentID]) ON DELETE CASCADE,
    CONSTRAINT [FK_Com_AmendmentAmenities_Station] FOREIGN KEY ([HousingStationCode]) REFERENCES dbo.[Lkp_AirportStations] ([StationCode])
);
GO

-- ----------------------------------------------------------------------------
-- Table 23 of 26: dbo.[Com_AmendmentStations]  (3. Versioning, Renewals & Operational Amendments)
-- ----------------------------------------------------------------------------
-- Airport stations appended to an existing contract via an Amendment (Airport Stations Network Expansion section).
CREATE TABLE dbo.[Com_AmendmentStations] (
    [AmendmentID] INT NOT NULL,
    [StationCode] NVARCHAR(10) NOT NULL,
    [MonthlyStationFeeUSD] DECIMAL(12, 2) NOT NULL CONSTRAINT [DF_Com_AmendmentStations_MonthlyStationFeeUSD] DEFAULT (1200.00),
    CONSTRAINT [PK_Com_AmendmentStations] PRIMARY KEY CLUSTERED ([AmendmentID] ASC, [StationCode] ASC),
    CONSTRAINT [FK_Com_AmendmentStations_Amendments] FOREIGN KEY ([AmendmentID]) REFERENCES dbo.[Com_ContractAmendments] ([AmendmentID]) ON DELETE CASCADE,
    CONSTRAINT [FK_Com_AmendmentStations_Stations] FOREIGN KEY ([StationCode]) REFERENCES dbo.[Lkp_AirportStations] ([StationCode])
);
GO

-- ----------------------------------------------------------------------------
-- Table 24 of 26: dbo.[Com_AmendmentFleetModels]  (3. Versioning, Renewals & Operational Amendments)
-- ----------------------------------------------------------------------------
-- Aircraft fleet models appended to an existing contract via an Amendment (Covered Airfleet Models Expansion section).
CREATE TABLE dbo.[Com_AmendmentFleetModels] (
    [AmendmentID] INT NOT NULL,
    [ModelCode] NVARCHAR(20) NOT NULL,
    [MonthlyFleetFeeUSD] DECIMAL(12, 2) NOT NULL CONSTRAINT [DF_Com_AmendmentFleetModels_MonthlyFleetFeeUSD] DEFAULT (750.00),
    CONSTRAINT [PK_Com_AmendmentFleetModels] PRIMARY KEY CLUSTERED ([AmendmentID] ASC, [ModelCode] ASC),
    CONSTRAINT [FK_Com_AmendmentFleetModels_Amendments] FOREIGN KEY ([AmendmentID]) REFERENCES dbo.[Com_ContractAmendments] ([AmendmentID]) ON DELETE CASCADE,
    CONSTRAINT [FK_Com_AmendmentFleetModels_Models] FOREIGN KEY ([ModelCode]) REFERENCES dbo.[Lkp_AircraftModels] ([ModelCode])
);
GO

-- ----------------------------------------------------------------------------
-- Table 25 of 26: dbo.[Com_AmendmentServices]  (3. Versioning, Renewals & Operational Amendments)
-- ----------------------------------------------------------------------------
-- Auxiliary ramp turnaround GSE utilities (GPU, ASU, ACU, Pushback, Lavatory, Cabin Clean) appended via an Amendment.
CREATE TABLE dbo.[Com_AmendmentServices] (
    [AmendmentID] INT NOT NULL,
    [ServiceCode] NVARCHAR(30) NOT NULL,
    [MonthlyAddendumFeeUSD] DECIMAL(12, 2) NOT NULL,
    CONSTRAINT [PK_Com_AmendmentServices] PRIMARY KEY CLUSTERED ([AmendmentID] ASC, [ServiceCode] ASC),
    CONSTRAINT [FK_Com_AmendmentServices_Amendments] FOREIGN KEY ([AmendmentID]) REFERENCES dbo.[Com_ContractAmendments] ([AmendmentID]) ON DELETE CASCADE,
    CONSTRAINT [FK_Com_AmendmentServices_Services] FOREIGN KEY ([ServiceCode]) REFERENCES dbo.[Lkp_GroundServices] ([ServiceCode])
);
GO

-- ----------------------------------------------------------------------------
-- Table 26 of 26: dbo.[Sec_ContractAuditLog]  (5. Roles, Users & Approval Audit)
-- ----------------------------------------------------------------------------
-- Immutable governance audit log recording draft creations, edits (auto-reset to Draft + version bump), Commercial Admin approvals, renewals, and amendments.
CREATE TABLE dbo.[Sec_ContractAuditLog] (
    [AuditLogID] BIGINT IDENTITY(1,1) NOT NULL,
    [ContractID] INT NULL,
    [ActionType] NVARCHAR(40) NOT NULL,
    [PreviousStatus] NVARCHAR(20) NULL,
    [NewStatus] NVARCHAR(20) NULL,
    [VersionLabel] NVARCHAR(30) NULL,
    [ActionDetails] NVARCHAR(600) NOT NULL,
    [PerformedByUserID] INT NOT NULL,
    [PerformedAt] DATETIME2(0) NOT NULL CONSTRAINT [DF_Sec_ContractAuditLog_PerformedAt] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_Sec_ContractAuditLog] PRIMARY KEY CLUSTERED ([AuditLogID] ASC),
    CONSTRAINT [FK_Sec_ContractAuditLog_Contracts] FOREIGN KEY ([ContractID]) REFERENCES dbo.[Com_Contracts] ([ContractID]),
    CONSTRAINT [FK_Sec_ContractAuditLog_Users] FOREIGN KEY ([PerformedByUserID]) REFERENCES dbo.[Sec_Users] ([UserID])
);
GO

-- ============================================================================
-- SECTION 4: PERFORMANCE INDEXES (Contracts Registry Filters, Lookups & Joins)
-- ============================================================================
CREATE NONCLUSTERED INDEX [IX_Com_Contracts_Status_ValidTo]
    ON dbo.[Com_Contracts] ([ContractStatus] ASC, [ValidToDate] ASC)
    INCLUDE ([ContractRef], [CustomerID], [CategoryCode], [PrimaryStationCode], [AnnualContractValueUSD], [ProfitMarginPct], [CurrentVersionLabel]);
GO

CREATE NONCLUSTERED INDEX [IX_Com_Contracts_ActivePeriodDates]
    ON dbo.[Com_Contracts] ([EffectiveFromDate] ASC, [ValidToDate] ASC, [CreatedDate] DESC)
    INCLUDE ([ContractStatus], [AnnualContractValueUSD], [PaymentTermCode]);
GO

CREATE NONCLUSTERED INDEX [IX_Com_Contracts_Customer_PrimaryStation]
    ON dbo.[Com_Contracts] ([CustomerID] ASC, [PrimaryStationCode] ASC, [CategoryCode] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_Flt_AircraftRegistrations_Customer_Model]
    ON dbo.[Flt_AircraftRegistrations] ([CustomerID] ASC, [ModelCode] ASC)
    INCLUDE ([CertifiedMtowTons], [PassengerSeats], [OwnershipStatus], [OperationalStatus]);
GO

CREATE NONCLUSTERED INDEX [IX_Com_ContractVersions_Contract_Latest]
    ON dbo.[Com_ContractVersions] ([ContractID] ASC, [IsLatestVersion] DESC, [ContractVersionID] DESC);
GO

CREATE NONCLUSTERED INDEX [IX_Com_ContractAmendments_ContractID]
    ON dbo.[Com_ContractAmendments] ([ContractID] ASC, [EffectiveDate] DESC);
GO

CREATE NONCLUSTERED INDEX [IX_Com_ContractRenewals_ContractID]
    ON dbo.[Com_ContractRenewals] ([ContractID] ASC, [RenewedAt] DESC);
GO

CREATE NONCLUSTERED INDEX [IX_Sec_ContractAuditLog_Contract_Time]
    ON dbo.[Sec_ContractAuditLog] ([ContractID] ASC, [PerformedAt] DESC);
GO

-- ============================================================================
-- SECTION 5: MASTER LOOKUPS & APPLICATION SEED DATA
-- Matches all 9 Master Lookup Catalogs & Contract Lifecycle Workflows
-- ============================================================================
SET NOCOUNT ON;
GO

-- 5.1 Security Roles (2 rows: Commercial Desk vs Commercial Admin)
INSERT INTO dbo.[Sec_Roles]
    ([RoleCode], [RoleDisplayName], [RoleBadgeLabel], [CanCreateDraft], [CanEditLatestVersion], [CanApproveAndActivate], [CanExecuteAmendments], [CanManageMasterLookups])
VALUES
    (N'COMMERCIAL_DESK',  N'Commercial Desk Officer',       N'Commercial Desk (Draft mode)',    1, 1, 0, 1, 1),
    (N'COMMERCIAL_ADMIN', N'Commercial Admin & Approver',   N'Commercial Admin (Full Approval)', 1, 1, 1, 1, 1);
GO

-- 5.2 Portal Users (4 rows)
SET IDENTITY_INSERT dbo.[Sec_Users] ON;
INSERT INTO dbo.[Sec_Users]
    ([UserID], [Username], [FullName], [AvatarInitials], [Email], [RoleCode], [Department], [IsActive])
VALUES
    (1, N'tarek.mostafa',  N'Tarek Mostafa',   N'TM', N'tarek.mostafa@tas-aviation.eg',  N'COMMERCIAL_DESK',  N'Commercial Contracts Desk',      1),
    (2, N'hatem.hazaa',    N'Hatem Hazaa',     N'HH', N'hatem.hazaa@tas-aviation.eg',    N'COMMERCIAL_ADMIN', N'Executive Commercial & Pricing', 1),
    (3, N'nadia.mansour',  N'Nadia Mansour',   N'NM', N'nadia.mansour@tas-aviation.eg',  N'COMMERCIAL_DESK',  N'Airline Alliances & SGHA Desk',  1),
    (4, N'karim.elmasry',  N'Karim El-Masry',  N'KM', N'karim.elmasry@tas-aviation.eg',  N'COMMERCIAL_ADMIN', N'Commercial Legal & Governance',  1);
SET IDENTITY_INSERT dbo.[Sec_Users] OFF;
GO

-- 5.3 Master Lookup #6: Billing Currencies (6 rows)
INSERT INTO dbo.[Lkp_Currencies]
    ([CurrencyCode], [CurrencySymbol], [CurrencyName], [ExchangeRateToUSD], [IsBaseCurrency], [DisplayFormat], [IsActive])
VALUES
    (N'USD', N'$',   N'US Dollar',              1.000000, 1, N'USD ($) — US Dollar (Base)',      1),
    (N'EUR', N'€',   N'Euro',                   0.920000, 0, N'EUR (€) — Euro',                  1),
    (N'EGP', N'EGP', N'Egyptian Pound',        48.500000, 0, N'EGP (EGP) — Egyptian Pound',      1),
    (N'SAR', N'SAR', N'Saudi Riyal',            3.750000, 0, N'SAR (SAR) — Saudi Riyal',         1),
    (N'AED', N'AED', N'UAE Dirham',             3.670000, 0, N'AED (AED) — UAE Dirham',          1),
    (N'GBP', N'£',   N'British Pound Sterling', 0.780000, 0, N'GBP (£) — British Pound',         1);
GO

-- 5.4 Master Lookup #7: Payment & Credit Terms (6 rows)
INSERT INTO dbo.[Lkp_PaymentTerms]
    ([PaymentTermCode], [TermName], [CreditSettlementDays], [CreditRiskCategory], [BillingCycleDesc], [IsActive])
VALUES
    (N'NET30',    N'Net 30 Days (Standard Scheduled)', 30, N'Standard Credit',     N'Invoiced monthly, payable within 30 calendar days',               1),
    (N'NET14',    N'Net 14 Days (Regional Alliances)', 14, N'Short Credit',        N'Bi-weekly billing cycle for regional charter & LCC',              1),
    (N'PROFORMA', N'100% Proforma Advance (Charters)',  0, N'Advance / Zero Risk', N'Pre-flight prepayment required prior to turnaround departure',    1),
    (N'NET60',    N'Net 60 Days (Strategic Long-Term)',60, N'Extended Credit',     N'Reserved for primary legacy flag carriers',                       1),
    (N'NET45',    N'Net 45 Days (Extended Alliance)',  45, N'Extended Credit',     N'Alliance partners with bank guarantee on file',                   1),
    (N'NET7',     N'Net 7 Days (Weekly Settlement)',    7, N'Short Credit',        N'Weekly billing reconciliation for ad-hoc high frequency',         1);
GO

-- 5.5 Master Lookup #8: SGHA Agreement Standards (6 rows)
INSERT INTO dbo.[Lkp_SghaStandards]
    ([SghaStandardCode], [EditionRelease], [StandardFullName], [GoverningBody], [StandardDescription], [IsActive])
VALUES
    (N'SGHA_2018',  N'2018',    N'IATA SGHA 2018 (Standard Ground Handling)', N'IATA IGHC Council',   N'Main Annex A & Annex B standard ground handling agreement',                      1),
    (N'SGHA_2013',  N'2013',    N'IATA SGHA 2013',                            N'IATA IGHC Council',   N'Prior standard SGHA framework with simplified liability clauses',                1),
    (N'SGHA_2023',  N'2023',    N'IATA SGHA 2023 Edition',                    N'IATA IGHC Council',   N'Latest standard with modernized sustainability & PRM electronic data SLAs',      1),
    (N'SGHA_2008',  N'2008',    N'IATA SGHA 2008',                            N'IATA IGHC Council',   N'Legacy standard agreement retained for continuous legacy contracts',             1),
    (N'ADHOC',      N'Ad-hoc',  N'Single Ad-hoc Charter Agreement',           N'TAS Commercial',      N'Turnaround contract for ad-hoc cargo, VIP, or non-scheduled tech stops',         1),
    (N'CUSTOM_SLA', N'Bespoke', N'Custom Bilateral Commercial SLA',           N'Bilateral Agreement', N'Non-standard customized ground operations SLA with bespoke penalty credits',     1);
GO

-- 5.6 Carrier Operating Categories (5 rows)
INSERT INTO dbo.[Lkp_CarrierCategories]
    ([CategoryCode], [CategoryName], [DefaultTargetMarginPct], [SortOrder], [IsActive])
VALUES
    (N'COMMERCIAL', N'Commercial Scheduled',   27.50, 1, 1),
    (N'CHARTER',    N'Leisure & Charter',      26.00, 2, 1),
    (N'CARGO',      N'Cargo & Freight',        29.80, 3, 1),
    (N'LCC',        N'Low-Cost Carrier (LCC)', 25.80, 4, 1),
    (N'VIP',        N'Private & Business VIP', 33.20, 5, 1);
GO

-- 5.7 Master Lookup #2: Authorized Egyptian Airport Stations (15 rows)
INSERT INTO dbo.[Lkp_AirportStations]
    ([StationCode], [AirportName], [RegionGovernorate], [CountryName], [IsPrimaryHubEligible], [IsActive])
VALUES
    (N'CAI', N'Cairo International Airport',           N'Cairo Hub',       N'Egypt', 1, 1),
    (N'HRG', N'Hurghada International Airport',        N'Red Sea',         N'Egypt', 1, 1),
    (N'SSH', N'Sharm El Sheikh International Airport', N'South Sinai',     N'Egypt', 1, 1),
    (N'LXR', N'Luxor International Airport',           N'Upper Egypt',     N'Egypt', 1, 1),
    (N'HBE', N'Borg El Arab Airport',                  N'Alexandria',      N'Egypt', 1, 1),
    (N'ASW', N'Aswan International Airport',           N'Aswan',           N'Egypt', 1, 1),
    (N'RMF', N'Marsa Alam International Airport',      N'Red Sea',         N'Egypt', 1, 1),
    (N'SPX', N'Sphinx International Airport',          N'Giza / Pyramids', N'Egypt', 1, 1),
    (N'DBB', N'Al Alamein International Airport',      N'North Coast',     N'Egypt', 1, 1),
    (N'TCP', N'Taba International Airport',            N'Sinai Peninsula', N'Egypt', 0, 1),
    (N'ATZ', N'Assiut International Airport',          N'Upper Egypt',     N'Egypt', 0, 1),
    (N'MUH', N'Marsa Matruh International Airport',    N'Matruh',          N'Egypt', 0, 1),
    (N'AAC', N'Al Arish International Airport',        N'North Sinai',     N'Egypt', 0, 1),
    (N'SKH', N'St. Catherine International Airport',   N'Sinai',           N'Egypt', 0, 1),
    (N'UVL', N'New Valley Airport',                    N'Kharga Oasis',    N'Egypt', 0, 1);
GO

-- 5.8 Master Lookup #9: Apron Stand & Boarding Policies (5 rows)
INSERT INTO dbo.[Lkp_ApronPolicies]
    ([ApronPolicyCode], [PolicyName], [StandCategory], [TransferBoardingMethod], [OperationalSlaNotes], [IsActive])
VALUES
    (N'CONTACT',    N'Contact Gate with Passenger Boarding Bridge',  N'Contact Gate',  N'Passenger Boarding Bridge (Jetbridge)', N'Terminal finger contact gate with dual-door direct passenger boarding bridge',                   1),
    (N'COBUS',      N'Remote Stand with Cobus Passenger Transfer',   N'Remote Stand',  N'Cobus Airside Shuttle Bus',             N'Remote apron parking position served by dedicated high-capacity airside shuttle buses',          1),
    (N'WALK',       N'Remote Walk-in Stand',                         N'Walk-in Stand', N'Covered Apron Walkway & Stairs',        N'Pedestrian walk-in stand adjacent to terminal with covered ground walkway and mobile stairs',     1),
    (N'VIP_STAND',  N'VIP Dedicated Presidential Apron Stand',       N'VIP Ramp',      N'VIP Executive Chauffeur Limousine',     N'Dedicated presidential / royal apron stand with private ramp escort and executive lounge access', 1),
    (N'CARGO_RAMP', N'Dedicated Cargo Freight Ramp Stand',           N'Cargo Ramp',    N'Maindeck High-Loader & Tractor Tow',    N'Heavy freight parking ramp with specialized main-deck cargo handling and GSE priority',           1);
GO

-- 5.9 Maximum Takeoff Weight (MTOW) Billing Tiers (4 rows)
INSERT INTO dbo.[Lkp_MtowTiers]
    ([MtowTierCode], [TierDisplayName], [MinWeightTons], [MaxWeightTons], [SortOrder])
VALUES
    (N'NARROW',   N'Tier 1: Narrowbody (50 to 100 Tons)',    50.00, 100.00, 1),
    (N'WIDE',     N'Tier 2: Widebody (100 to 250 Tons)',    100.01, 250.00, 2),
    (N'HEAVY',    N'Tier 3: Heavy Aircraft (>250 Tons)',    250.01,   NULL, 3),
    (N'REGIONAL', N'Tier 4: Regional Turboprop (<50 Tons)',   0.00,  49.99, 4);
GO

-- 5.10 Master Lookup #3: Aircraft Fleet Models (23 rows)
INSERT INTO dbo.[Lkp_AircraftModels]
    ([ModelCode], [ManufacturerDesc], [MtowTierCode], [IsCargoFreighter], [DefaultTurnaroundMins], [IsActive])
VALUES
    (N'A320',  N'Airbus A320ceo/neo',            N'NARROW',   0, 45, 1),
    (N'A321',  N'Airbus A321ceo/neo/LR',         N'NARROW',   0, 50, 1),
    (N'A332',  N'Airbus A330-200',               N'WIDE',     0, 75, 1),
    (N'A333',  N'Airbus A330-300',               N'WIDE',     0, 80, 1),
    (N'A339',  N'Airbus A330-900neo',            N'WIDE',     0, 80, 1),
    (N'A359',  N'Airbus A350-900 XWB',           N'WIDE',     0, 85, 1),
    (N'A351',  N'Airbus A350-1000 XWB',          N'WIDE',     0, 90, 1),
    (N'B738',  N'Boeing 737-800 NG',             N'NARROW',   0, 45, 1),
    (N'B739',  N'Boeing 737-900ER',              N'NARROW',   0, 50, 1),
    (N'B38M',  N'Boeing 737 MAX 8',              N'NARROW',   0, 45, 1),
    (N'B39M',  N'Boeing 737 MAX 9',              N'NARROW',   0, 50, 1),
    (N'B77W',  N'Boeing 777-300ER',              N'WIDE',     0, 90, 1),
    (N'B77F',  N'Boeing 777F Freighter',         N'HEAVY',    1, 110, 1),
    (N'B788',  N'Boeing 787-8 Dreamliner',       N'WIDE',     0, 75, 1),
    (N'B789',  N'Boeing 787-9 Dreamliner',       N'WIDE',     0, 80, 1),
    (N'B78X',  N'Boeing 787-10 Dreamliner',      N'WIDE',     0, 85, 1),
    (N'B744F', N'Boeing 747-400F Cargo Jumbo',   N'HEAVY',    1, 120, 1),
    (N'A332F', N'Airbus A330-200F Cargo',        N'HEAVY',    1, 105, 1),
    (N'B738F', N'Boeing 737-800 BCF Freighter',  N'NARROW',   1, 65, 1),
    (N'E190',  N'Embraer E190 E-Jet',            N'REGIONAL', 0, 35, 1),
    (N'E195',  N'Embraer E195-E2',               N'REGIONAL', 0, 35, 1),
    (N'AT76',  N'ATR 72-600 Turboprop',          N'REGIONAL', 0, 30, 1),
    (N'DH8D',  N'De Havilland Dash 8-400',       N'REGIONAL', 0, 30, 1);
GO

-- 5.11 Master Lookup #1: Airline & Carrier Customers (24 rows)
INSERT INTO dbo.[Ar_AirlineCustomers]
    ([CustomerID], [CarrierDisplayCode], [IataCode], [IcaoCode], [CustomerFullName], [CategoryCode], [DefaultPaymentTermCode], [DefaultCurrencyCode], [PrimaryHubStationCode], [CountryRegion], [IsActive])
VALUES
    (N'MS_HOLDING',   N'MS / MSR',  N'MS',  N'MSR', N'EgyptAir Holding Company',          N'COMMERCIAL', N'NET30',    N'USD', N'CAI', N'Egypt',                1),
    (N'SM_AIRCAIRO',  N'SM / MSC',  N'SM',  N'MSC', N'Air Cairo',                         N'COMMERCIAL', N'NET30',    N'USD', N'CAI', N'Egypt',                1),
    (N'NE_NESMA',     N'NE / NMA',  N'NE',  N'NMA', N'Nesma Airlines',                    N'COMMERCIAL', N'NET30',    N'USD', N'CAI', N'Egypt',                1),
    (N'NP_NILE',      N'NP / NIA',  N'NP',  N'NIA', N'Nile Air',                          N'COMMERCIAL', N'NET30',    N'USD', N'CAI', N'Egypt',                1),
    (N'FZ_TOUR',      N'FZ / FDB',  N'FZ',  N'FDB', N'Flydubai Aviation',                 N'CHARTER',    N'PROFORMA', N'USD', N'SSH', N'United Arab Emirates', 1),
    (N'TK_CARGO',     N'TK / THY',  N'TK',  N'THY', N'Turkish Airlines',                  N'COMMERCIAL', N'NET30',    N'USD', N'CAI', N'Turkey',               1),
    (N'SV_SAUDIA',    N'SV / SVA',  N'SV',  N'SVA', N'Saudia Airlines',                   N'COMMERCIAL', N'NET30',    N'SAR', N'CAI', N'Saudi Arabia',         1),
    (N'XY_FLYNAS',    N'XY / KNE',  N'XY',  N'KNE', N'Flynas Airline',                    N'LCC',        N'NET30',    N'SAR', N'CAI', N'Saudi Arabia',         1),
    (N'LH_LUFTHANSA', N'LH / DLH',  N'LH',  N'DLH', N'Lufthansa German Airlines',         N'COMMERCIAL', N'NET30',    N'EUR', N'CAI', N'Germany',              1),
    (N'EK_EMIRATES',  N'EK / UAE',  N'EK',  N'UAE', N'Emirates Airline',                  N'COMMERCIAL', N'NET30',    N'USD', N'CAI', N'United Arab Emirates', 1),
    (N'QR_QATAR',     N'QR / QTR',  N'QR',  N'QTR', N'Qatar Airways',                     N'COMMERCIAL', N'NET30',    N'USD', N'CAI', N'Qatar',                1),
    (N'EY_ETIHAD',    N'EY / ETD',  N'EY',  N'ETD', N'Etihad Airways',                    N'COMMERCIAL', N'NET30',    N'AED', N'CAI', N'United Arab Emirates', 1),
    (N'BA_BRITISH',   N'BA / BAW',  N'BA',  N'BAW', N'British Airways',                   N'COMMERCIAL', N'NET30',    N'GBP', N'CAI', N'United Kingdom',       1),
    (N'AF_AIRFRANCE', N'AF / AFR',  N'AF',  N'AFR', N'Air France',                        N'COMMERCIAL', N'NET30',    N'EUR', N'CAI', N'France',               1),
    (N'WZ_WIZZAIR',   N'W6 / WZZ',  N'W6',  N'WZZ', N'Wizz Air Hungary / Abu Dhabi',      N'LCC',        N'PROFORMA', N'EUR', N'SPX', N'Hungary',              1),
    (N'DH_DHL',       N'ES / DHX',  N'ES',  N'DHX', N'DHL Aviation Middle East',          N'CARGO',      N'NET30',    N'USD', N'CAI', N'Bahrain',              1),
    (N'FT_FLYEGYPT',  N'FT / FEG',  N'FT',  N'FEG', N'FlyEgypt Charter Services',         N'CHARTER',    N'PROFORMA', N'USD', N'HRG', N'Egypt',                1),
    (N'QS_SMARTWINGS',N'QS / TVS',  N'QS',  N'TVS', N'Smartwings Czechia',                N'CHARTER',    N'PROFORMA', N'EUR', N'HRG', N'Czechia',              1),
    (N'U2_EASYJET',   N'U2 / EZY',  N'U2',  N'EZY', N'EasyJet Airline UK',                N'CHARTER',    N'NET14',    N'GBP', N'HRG', N'United Kingdom',       1),
    (N'DE_CONDOR',    N'DE / CFG',  N'DE',  N'CFG', N'Condor Flugdienst Germany',         N'CHARTER',    N'NET14',    N'EUR', N'HRG', N'Germany',              1),
    (N'CV_CARGOLUX',  N'CV / CLX',  N'CV',  N'CLX', N'Cargolux Airlines International',   N'CARGO',      N'NET30',    N'USD', N'CAI', N'Luxembourg',           1),
    (N'SME_SMARTVIP', N'SME / SME', N'SME', N'SME', N'Smart Aviation Egypt (VIP)',        N'VIP',        N'PROFORMA', N'USD', N'CAI', N'Egypt',                1),
    (N'ROJ_ROYALJET', N'ROJ / ROJ', N'ROJ', N'ROJ', N'Royal Jet Abu Dhabi (VIP)',         N'VIP',        N'PROFORMA', N'USD', N'CAI', N'United Arab Emirates', 1),
    (N'G9_AIRARABIA', N'G9 / ABY',  N'G9',  N'ABY', N'Air Arabia',                        N'LCC',        N'NET30',    N'AED', N'HBE', N'United Arab Emirates', 1);
GO

-- 5.12 Master Lookup #4: Aircraft Registrations (37 rows — keyed by RegistrationNo)
INSERT INTO dbo.[Flt_AircraftRegistrations]
    ([RegistrationNo], [CustomerID], [ModelCode], [OperatingCarrierCode], [VariantModelName], [CertifiedMtowTons], [PassengerSeats], [OwnershipStatus], [IsLeased], [OperationalStatus])
VALUES
    -- EgyptAir Fleet (11 registrations)
    (N'SU-GBF',  N'MS_HOLDING',    N'A320',  N'MS / MSR',  N'Airbus A320-200',         77.00, 168, N'OWNED',      0, N'Active'),
    (N'SU-GBD',  N'MS_HOLDING',    N'A320',  N'MS / MSR',  N'Airbus A320-200',         77.00, 168, N'OWNED',      0, N'Active'),
    (N'SU-GCT',  N'MS_HOLDING',    N'A321',  N'MS / MSR',  N'Airbus A321neo',          93.50, 198, N'OWNED',      0, N'Active'),
    (N'SU-GCU',  N'MS_HOLDING',    N'A321',  N'MS / MSR',  N'Airbus A321neo',          93.50, 198, N'OWNED',      0, N'Active'),
    (N'SU-GDM',  N'MS_HOLDING',    N'B738',  N'MS / MSR',  N'Boeing 737-800 NG',       79.00, 160, N'OWNED',      0, N'Active'),
    (N'SU-GDN',  N'MS_HOLDING',    N'B738',  N'MS / MSR',  N'Boeing 737-800 NG',       79.00, 160, N'OWNED',      0, N'Active'),
    (N'SU-GEZ',  N'MS_HOLDING',    N'B789',  N'MS / MSR',  N'Boeing 787-9 Dreamliner',254.00, 309, N'OWNED',      0, N'Active'),
    (N'SU-GEY',  N'MS_HOLDING',    N'B789',  N'MS / MSR',  N'Boeing 787-9 Dreamliner',254.00, 309, N'OWNED',      0, N'Active'),
    (N'SU-GDL',  N'MS_HOLDING',    N'B77W',  N'MS / MSR',  N'Boeing 777-300ER',       351.50, 365, N'OWNED',      0, N'Active'),
    (N'SU-GCE',  N'MS_HOLDING',    N'A332F', N'MSX / MSX', N'Airbus A330-200F Cargo', 233.00,   0, N'OWNED',      0, N'Active Cargo'),
    (N'SU-GCF',  N'MS_HOLDING',    N'B738F', N'MSX / MSX', N'Boeing 737-800 BCF',      79.00,   0, N'OWNED',      0, N'Active Cargo'),
    -- Air Cairo Fleet (4 registrations)
    (N'SU-BTM',  N'SM_AIRCAIRO',   N'A320',  N'SM / MSC',  N'Airbus A320neo',          79.00, 186, N'OWNED',      0, N'Active'),
    (N'SU-BTN',  N'SM_AIRCAIRO',   N'A320',  N'SM / MSC',  N'Airbus A320neo',          79.00, 186, N'OWNED',      0, N'Active'),
    (N'SU-BTO',  N'SM_AIRCAIRO',   N'AT76',  N'SM / MSC',  N'ATR 72-600 Turboprop',    23.00,  70, N'OWNED',      0, N'Active'),
    (N'SU-BTP',  N'SM_AIRCAIRO',   N'E190',  N'SM / MSC',  N'Embraer E190 E-Jet',      51.80, 110, N'OWNED',      0, N'Active'),
    -- FlyEgypt Leased Registrations (2 registrations)
    (N'SU-FGA',  N'FT_FLYEGYPT',   N'B738',  N'FT / FEG',  N'Boeing 737-800 NG',       79.00, 189, N'LEASED_DRY', 1, N'Active'),
    (N'SU-FGB',  N'FT_FLYEGYPT',   N'B738',  N'FT / FEG',  N'Boeing 737-800 NG',       79.00, 189, N'LEASED_DRY', 1, N'Active'),
    -- Nile Air (2 registrations)
    (N'SU-BQM',  N'NP_NILE',       N'A320',  N'NP / NIA',  N'Airbus A320-200',         77.00, 164, N'OWNED',      0, N'Active'),
    (N'SU-BQN',  N'NP_NILE',       N'A321',  N'NP / NIA',  N'Airbus A321-200',         89.00, 204, N'OWNED',      0, N'Active'),
    -- Nesma Airlines (2 registrations)
    (N'SU-NMA',  N'NE_NESMA',      N'A320',  N'NE / NMA',  N'Airbus A320-200',         77.00, 180, N'OWNED',      0, N'Active'),
    (N'SU-NMB',  N'NE_NESMA',      N'AT76',  N'NE / NMA',  N'ATR 72-600 Turboprop',    23.00,  72, N'OWNED',      0, N'Active'),
    -- Smartwings (2 registrations)
    (N'OK-TVF',  N'QS_SMARTWINGS', N'B738',  N'QS / TVS',  N'Boeing 737-800 NG',       79.00, 189, N'OWNED',      0, N'Active'),
    (N'OK-TVS',  N'QS_SMARTWINGS', N'B38M',  N'QS / TVS',  N'Boeing 737 MAX 8',        82.20, 189, N'OWNED',      0, N'Active'),
    -- Saudia Airlines (2 registrations)
    (N'HZ-AQ1',  N'SV_SAUDIA',     N'A320',  N'SV / SVA',  N'Airbus A320-200',         77.00, 144, N'OWNED',      0, N'Active'),
    (N'HZ-AK24', N'SV_SAUDIA',     N'B77W',  N'SV / SVA',  N'Boeing 777-300ER',       351.50, 413, N'OWNED',      0, N'Active'),
    -- Emirates (2 registrations)
    (N'A6-ENA',  N'EK_EMIRATES',   N'B77W',  N'EK / UAE',  N'Boeing 777-300ER',       351.50, 354, N'OWNED',      0, N'Active'),
    (N'A6-EQP',  N'EK_EMIRATES',   N'B77W',  N'EK / UAE',  N'Boeing 777-300ER',       351.50, 360, N'OWNED',      0, N'Active'),
    -- Turkish Airlines (2 registrations)
    (N'TC-LNC',  N'TK_CARGO',      N'A333',  N'TK / THY',  N'Airbus A330-300',        242.00, 289, N'OWNED',      0, N'Active'),
    (N'TC-JVD',  N'TK_CARGO',      N'B738',  N'TK / THY',  N'Boeing 737-800 NG',       79.00, 165, N'OWNED',      0, N'Active'),
    -- Lufthansa (2 registrations)
    (N'D-AINZ',  N'LH_LUFTHANSA',  N'A320',  N'LH / DLH',  N'Airbus A320neo',          79.00, 180, N'OWNED',      0, N'Active'),
    (N'D-AIEA',  N'LH_LUFTHANSA',  N'A321',  N'LH / DLH',  N'Airbus A321neo',          93.50, 215, N'OWNED',      0, N'Active'),
    -- British Airways (2 registrations)
    (N'G-EUYR',  N'BA_BRITISH',    N'A320',  N'BA / BAW',  N'Airbus A320-200',         77.00, 180, N'OWNED',      0, N'Active'),
    (N'G-ZBKA',  N'BA_BRITISH',    N'B789',  N'BA / BAW',  N'Boeing 787-9 Dreamliner',254.00, 216, N'OWNED',      0, N'Active'),
    -- Qatar Airways (2 registrations)
    (N'A7-BAC',  N'QR_QATAR',      N'B77W',  N'QR / QTR',  N'Boeing 777-300ER',       351.50, 358, N'OWNED',      0, N'Active'),
    (N'A7-BHI',  N'QR_QATAR',      N'B789',  N'QR / QTR',  N'Boeing 787-9 Dreamliner',254.00, 311, N'OWNED',      0, N'Active'),
    -- Wizz Air (2 registrations)
    (N'HA-LVI',  N'WZ_WIZZAIR',    N'A321',  N'W6 / WZZ',  N'Airbus A321neo',          97.00, 239, N'OWNED',      0, N'Active'),
    (N'HA-LVM',  N'WZ_WIZZAIR',    N'A321',  N'W6 / WZZ',  N'Airbus A321neo',          97.00, 239, N'OWNED',      0, N'Active');
GO

-- 5.13 Master Lookup #5: Ground Handling Services & GSE Equipment (18 rows)
INSERT INTO dbo.[Lkp_GroundServices]
    ([ServiceCode], [ServiceName], [StandardTariffUSD], [BillingUnit], [SghaAnnexSection], [IconSymbol], [IsAuxiliaryGse], [IsActive])
VALUES
    (N'GPU',        N'Ground Power Unit (400Hz GPU electrical)',             120.00, N'Per Sortie', N'SGHA Annex A Sec 3.3', N'⚡',  1, 1),
    (N'ASU',        N'Air Start Unit (High pressure jet turbine start)',     180.00, N'Per Start',  N'SGHA Annex A Sec 3.4', N'🌀',  1, 1),
    (N'ACU',        N'Air Conditioning Unit (Pre-conditioned cabin air)',    150.00, N'Per Sortie', N'SGHA Annex A Sec 3.5', N'❄️',  1, 1),
    (N'PUSH',       N'Aircraft Pushback & Apron Towing',                     220.00, N'Per Push',   N'SGHA Annex A Sec 3.6', N'🚜',  1, 1),
    (N'TOILET',     N'Lavatory / Toilet Servicing (Flush & replenish)',       95.00, N'Per Sortie', N'SGHA Annex A Sec 3.7', N'🚽',  1, 1),
    (N'WATER',      N'Potable Drinking Water Replenishment',                  75.00, N'Per Sortie', N'SGHA Annex A Sec 3.8', N'💧',  1, 1),
    (N'CLEAN',      N'Cabin Transit Cleaning & Trash Clearance',             160.00, N'Per Sortie', N'SGHA Annex A Sec 3.9', N'🧹',  1, 1),
    (N'BAGGAGE',    N'Baggage Handling, Loading & Ramp Conveyors',           240.00, N'Per Sortie', N'SGHA Annex A Sec 3.2', N'🧰',  0, 1),
    (N'DISPATCH',   N'Flight Dispatch & Load Control Weight/Balance',        130.00, N'Per Flight', N'SGHA Annex A Sec 4.1', N'📋',  0, 1),
    (N'COBUS',      N'Passenger Apron Transfer Bus (per sortie)',            110.00, N'Per Sortie', N'SGHA Annex A Sec 2.2', N'🚌',  1, 1),
    (N'CREW',       N'Dedicated Crew Van Transfer & Chaperone',               55.00, N'Per Trip',   N'SGHA Annex A Sec 2.3', N'🚐',  1, 1),
    (N'AMBULIFT',   N'PRM Passenger High-Lift Ambulift Vehicle',             140.00, N'Per Use',    N'SGHA Annex A Sec 2.1', N'♿',  1, 1),
    (N'DEICE',      N'De-icing / Anti-icing Apron Rig',                      350.00, N'Per Event',  N'SGHA Annex A Sec 3.11',N'🧊',  1, 1),
    (N'MARSHAL',    N'Apron Marshalling & Headset Interphone Comms',          60.00, N'Per Sortie', N'SGHA Annex A Sec 3.1', N'🛩️',  0, 1),
    (N'CARGO_LD',   N'High-Loader Main Deck Cargo GSE',                      310.00, N'Per Sortie', N'SGHA Annex A Sec 5.4', N'📦',  1, 1),
    (N'SECURITY',   N'Aircraft Security Hold & Cabin Search Inspection',     175.00, N'Per Sortie', N'SGHA Annex A Sec 8.1', N'🛡️',  0, 1),
    (N'WHEELCHAIR', N'Special PRM Wheelchair Assistance Service',             45.00, N'Per Pax',    N'SGHA Annex A Sec 2.1', N'♿',  0, 1),
    (N'STEPS',      N'Motorized Passenger Boarding Steps',                    85.00, N'Per Sortie', N'SGHA Annex A Sec 3.2', N'🪜',  1, 1);
GO

-- 5.14 Core Commercial Contracts (12 representative agreements across all lifecycle states)
SET IDENTITY_INSERT dbo.[Com_Contracts] ON;
INSERT INTO dbo.[Com_Contracts]
    ([ContractID], [ContractRef], [CustomerReference], [CustomerID], [CategoryCode], [ContractStatus], [CurrentVersionLabel], [PrimaryStationCode], [EffectiveFromDate], [ValidToDate], [CurrencyCode], [PaymentTermCode], [SghaStandardCode], [ApronPolicyCode], [MtowTierCode], [RegistrationScope], [ConcessionRoyaltyPct], [TurnaroundDurationMins], [MonthlyFlightVolume], [BaseNarrowRateUSD], [BaseWideRateUSD], [AnnualEscalationPct], [EstimatedMonthlyRevUSD], [AnnualContractValueUSD], [ProfitMarginPct], [CommercialRemarks], [CreatedDate], [CreatedByUserID], [ApprovedByUserID], [ApprovedAt])
VALUES
    (1,  N'TAS-CAI-2026-MS001',   N'MS-CORP-2026-A1',  N'MS_HOLDING',    N'COMMERCIAL', N'ACTIVE',   N'v1.1 (AMD)',     N'CAI', '2026-01-01', '2027-12-31', N'USD', N'NET30',    N'SGHA_2018', N'CONTACT',    N'WIDE',     N'CUSTOM', 12.00, 50, 121, 1650.00, 3200.00, 3.00, 484475.00, 5813700.00, 28.10, N'Flag carrier master handling agreement across 7 Egyptian stations with Hurghada AMD-1 expansion.', '2026-10-17', 1, 2, '2026-10-17T10:30:00'),
    (2,  N'TAS-CAI-2026-SM002',   N'SMC-2026-SCHED',   N'SM_AIRCAIRO',   N'COMMERCIAL', N'ACTIVE',   N'v1.0',           N'CAI', '2026-01-01', '2027-08-31', N'USD', N'NET30',    N'SGHA_2018', N'COBUS',      N'NARROW',   N'CUSTOM', 12.00, 45,  67, 1450.00,    NULL, 2.50, 202283.33, 2427400.00, 26.50, N'Scheduled & Red Sea feeder turnaround contract for Air Cairo A320neo, ATR72 and E190 fleet.',    '2026-10-17', 1, 2, '2026-10-17T11:15:00'),
    (3,  N'TAS-CAI-2026-SV003',   N'SVA-CAI-2026',     N'SV_SAUDIA',     N'COMMERCIAL', N'ACTIVE',   N'v1.0',           N'CAI', '2026-01-01', '2027-11-30', N'USD', N'NET30',    N'SGHA_2013', N'CONTACT',    N'WIDE',     N'CUSTOM', 12.00, 65,  74, 1550.00, 3400.00, 3.00, 290925.00, 3491100.00, 28.40, N'High-density widebody & narrowbody dual-bridge handling at CAI, HBE, and HRG.',                 '2026-10-16', 3, 2, '2026-10-16T14:20:00'),
    (4,  N'TAS-CAI-2026-NP004',   N'NIA-2026-DOM',     N'NP_NILE',       N'COMMERCIAL', N'ACTIVE',   N'v1.1 (AMD)',     N'CAI', '2026-01-01', '2027-10-31', N'USD', N'NET30',    N'SGHA_2023', N'COBUS',      N'NARROW',   N'CUSTOM', 12.00, 45,  59, 1420.00, 2650.00, 3.50, 179566.67, 2154800.00, 26.80, N'Nile Air passenger operations including Annex A Sharm El Sheikh & potable water servicing.',     '2026-10-16', 1, 4, '2026-10-16T16:00:00'),
    (5,  N'TAS-CAI-2026-EK005',   N'UAE-DXB-CAI-26',   N'EK_EMIRATES',   N'COMMERCIAL', N'ACTIVE',   N'v2.0 (Renewed)', N'CAI', '2026-02-01', '2028-01-31', N'USD', N'NET60',    N'SGHA_2023', N'CONTACT',    N'HEAVY',    N'CUSTOM', 14.00, 90,  76, 1800.00, 3850.00, 4.00, 360108.33, 4321300.00, 29.20, N'Strategic B777-300ER heavy turnaround SLA with dual airbridge & dedicated ULD high-loaders.',   '2026-10-14', 3, 2, '2026-10-15T09:45:00'),
    (6,  N'TAS-CAI-2026-ES006',   N'DHX-MENA-FRT26',   N'DH_DHL',        N'CARGO',      N'ACTIVE',   N'v1.0',           N'CAI', '2026-01-15', '2027-12-31', N'USD', N'NET30',    N'SGHA_2018', N'CARGO_RAMP', N'HEAVY',    N'ALL',    11.50, 95,  58, 1750.00, 3600.00, 3.00, 253666.67, 3044000.00, 30.20, N'Express main-deck cargo freighter ramp handling at Cairo Cargo Village.',                       '2026-10-10', 1, 2, '2026-10-11T12:10:00'),
    (7,  N'TAS-SPX-2026-W6007',   N'WZZ-SPX-LCC26',    N'WZ_WIZZAIR',    N'LCC',        N'ACTIVE',   N'v1.0',           N'SPX', '2026-03-01', '2027-09-30', N'EUR', N'PROFORMA', N'SGHA_2023', N'WALK',       N'NARROW',   N'CUSTOM', 10.50, 35,  55, 1320.00,    NULL, 2.00, 178500.00, 2142000.00, 25.70, N'Fast 35-minute LCC walk-in turnaround SLA at Sphinx (SPX), Borg El Arab (HBE), and Hurghada.', '2026-10-05', 3, 4, '2026-10-06T10:00:00'),
    (8,  N'TAS-HRG-2025-QS088',   N'TVS-CHARTER-25',   N'QS_SMARTWINGS', N'CHARTER',    N'EXPIRING', N'v1.0',           N'HRG', '2025-11-01', '2026-11-12', N'EUR', N'PROFORMA', N'SGHA_2018', N'COBUS',      N'NARROW',   N'CUSTOM', 12.00, 45,  40, 1380.00,    NULL, 3.00, 134500.00, 1614000.00, 26.40, N'Red Sea winter/summer leisure charter agreement approaching expiry window.',                    '2026-06-15', 1, 2, '2026-06-16T09:00:00'),
    (9,  N'TAS-SSH-2025-FZ102',   N'FDB-SINAI-25',     N'FZ_TOUR',       N'CHARTER',    N'RENEWAL',  N'v1.2 (AMD)',     N'SSH', '2025-10-15', '2026-11-05', N'USD', N'PROFORMA', N'SGHA_2018', N'COBUS',      N'NARROW',   N'ALL',    12.00, 40,  44, 1410.00,    NULL, 4.00, 154200.00, 1850400.00, 27.20, N'Currently under joint commercial committee renewal review for +2 years extension.',             '2026-05-12', 3, 2, '2026-05-13T15:30:00'),
    (10, N'TAS-CAI-2025-SME114',  N'SME-VIP-EXEC25',   N'SME_SMARTVIP',  N'VIP',        N'EXPIRED',  N'v1.0',           N'CAI', '2025-01-01', '2026-09-20', N'USD', N'PROFORMA', N'ADHOC',     N'VIP_STAND',  N'NARROW',   N'ALL',    15.00, 40,  24, 2100.00,    NULL, 0.00, 121833.33, 1462000.00, 33.50, N'Presidential & executive VIP ramp escort contract concluded; eligible for new season renewal.', '2025-09-10', 1, 4, '2025-09-11T11:00:00'),
    (11, N'TAS-CAI-2027-LH118',   N'DLH-FRA-CAI-27',   N'LH_LUFTHANSA',  N'COMMERCIAL', N'PENDING',  N'v1.0',           N'CAI', '2026-12-01', '2027-11-30', N'EUR', N'NET30',    N'SGHA_2023', N'CONTACT',    N'NARROW',   N'CUSTOM', 12.50, 50,  52, 1620.00, 3150.00, 3.00, 206750.00, 2481000.00, 27.80, N'Awaiting Commercial Admin final sign-off and legal audit approval.',                            '2026-10-28', 1, NULL, NULL),
    (12, N'TAS-HRG-2027-DE120',   N'CFG-REDSEA-2027',  N'DE_CONDOR',     N'CHARTER',    N'DRAFT',    N'v1.0',           N'HRG', '2026-12-15', '2027-12-14', N'EUR', N'NET14',    N'SGHA_2023', N'COBUS',      N'WIDE',     N'ALL',    12.00, 60,  46, 1480.00, 2890.00, 3.50, 159250.00, 1911000.00, 27.00, N'Initial draft prepared by Commercial Desk for Winter 2026/2027 German tourist charters.',       '2026-10-30', 1, NULL, NULL);
SET IDENTITY_INSERT dbo.[Com_Contracts] OFF;
GO

-- 5.15 Authorized Stations per Contract (43 rows)
INSERT INTO dbo.[Com_ContractStations] ([ContractID], [StationCode], [IsPrimaryHub], [SourceType])
VALUES
    -- Contract 1 (EgyptAir: 7 stations, HRG added/expanded in AMD-1)
    (1, N'CAI', 1, N'BASE'), (1, N'HRG', 0, N'AMENDMENT'), (1, N'SSH', 0, N'BASE'), (1, N'LXR', 0, N'BASE'),
    (1, N'HBE', 0, N'BASE'), (1, N'ASW', 0, N'BASE'),      (1, N'SPX', 0, N'BASE'),
    -- Contract 2 (Air Cairo: 6 stations)
    (2, N'CAI', 1, N'BASE'), (2, N'HRG', 0, N'BASE'), (2, N'SSH', 0, N'BASE'),
    (2, N'LXR', 0, N'BASE'), (2, N'HBE', 0, N'BASE'), (2, N'SPX', 0, N'BASE'),
    -- Contract 3 (Saudia: 3 stations)
    (3, N'CAI', 1, N'BASE'), (3, N'HBE', 0, N'BASE'), (3, N'HRG', 0, N'BASE'),
    -- Contract 4 (Nile Air: 6 stations, SSH via amendment)
    (4, N'CAI', 1, N'BASE'), (4, N'HRG', 0, N'BASE'), (4, N'SSH', 0, N'AMENDMENT'),
    (4, N'LXR', 0, N'BASE'), (4, N'HBE', 0, N'BASE'), (4, N'ASW', 0, N'BASE'),
    -- Contract 5 (Emirates: 2 stations)
    (5, N'CAI', 1, N'BASE'), (5, N'SPX', 0, N'BASE'),
    -- Contract 6 (DHL Cargo: 2 stations)
    (6, N'CAI', 1, N'BASE'), (6, N'HBE', 0, N'BASE'),
    -- Contract 7 (Wizz Air: 3 stations)
    (7, N'SPX', 1, N'BASE'), (7, N'HBE', 0, N'BASE'), (7, N'HRG', 0, N'BASE'),
    -- Contract 8 (Smartwings: 3 stations)
    (8, N'HRG', 1, N'BASE'), (8, N'SSH', 0, N'BASE'), (8, N'RMF', 0, N'BASE'),
    -- Contract 9 (Flydubai: 4 stations, DBB via amendment)
    (9, N'SSH', 1, N'BASE'), (9, N'HRG', 0, N'BASE'), (9, N'SPX', 0, N'BASE'), (9, N'DBB', 0, N'AMENDMENT'),
    -- Contract 10 (Smart Aviation VIP: 3 stations)
    (10, N'CAI', 1, N'BASE'), (10, N'DBB', 0, N'BASE'), (10, N'SSH', 0, N'BASE'),
    -- Contract 11 (Lufthansa: 2 stations)
    (11, N'CAI', 1, N'BASE'), (11, N'HRG', 0, N'BASE'),
    -- Contract 12 (Condor Draft: 2 stations)
    (12, N'HRG', 1, N'BASE'), (12, N'SSH', 0, N'BASE');
GO

-- 5.16 Covered Aircraft Fleet Models per Contract (31 rows)
INSERT INTO dbo.[Com_ContractFleetModels] ([ContractID], [ModelCode], [SourceType])
VALUES
    -- Contract 1 (5 models)
    (1, N'A320', N'BASE'), (1, N'A321', N'AMENDMENT'), (1, N'B738', N'BASE'), (1, N'B789', N'BASE'), (1, N'B77W', N'BASE'),
    -- Contract 2 (3 models)
    (2, N'A320', N'BASE'), (2, N'AT76', N'BASE'), (2, N'E190', N'BASE'),
    -- Contract 3 (3 models)
    (3, N'B77W', N'BASE'), (3, N'A333', N'BASE'), (3, N'A320', N'BASE'),
    -- Contract 4 (3 models)
    (4, N'A320', N'BASE'), (4, N'A321', N'BASE'), (4, N'B788', N'AMENDMENT'),
    -- Contract 5 (2 models)
    (5, N'B77W', N'BASE'), (5, N'A359', N'BASE'),
    -- Contract 6 (2 models)
    (6, N'B738F', N'BASE'), (6, N'B77F', N'BASE'),
    -- Contract 7 (2 models)
    (7, N'A321', N'BASE'), (7, N'A320', N'BASE'),
    -- Contract 8 (2 models)
    (8, N'B738', N'BASE'), (8, N'B38M', N'BASE'),
    -- Contract 9 (3 models)
    (9, N'B738', N'BASE'), (9, N'B38M', N'BASE'), (9, N'B39M', N'AMENDMENT'),
    -- Contract 10 (1 model)
    (10, N'A320', N'BASE'),
    -- Contract 11 (3 models)
    (11, N'A320', N'BASE'), (11, N'A321', N'BASE'), (11, N'A333', N'BASE'),
    -- Contract 12 (2 models)
    (12, N'A320', N'BASE'), (12, N'A333', N'BASE');
GO

-- 5.17 Specific Whitelisted Aircraft Registrations per Contract (16 rows)
INSERT INTO dbo.[Com_ContractRegistrations] ([ContractID], [RegistrationNo], [RegistrationNotes])
VALUES
    -- Contract 1 (EgyptAir designated registrations)
    (1, N'SU-GBF',  N'Primary CAI domestic/regional rotation'),
    (1, N'SU-GCT',  N'A321neo Red Sea & European hub feeder'),
    (1, N'SU-GDM',  N'B737-800 scheduled medium-haul'),
    (1, N'SU-GEZ',  N'B787-9 Dreamliner long-haul'),
    -- Contract 2 (Air Cairo)
    (2, N'SU-BTM',  N'Air Cairo A320neo primary'),
    (2, N'SU-BTO',  N'ATR 72-600 Upper Egypt shuttle'),
    -- Contract 3 (Saudia)
    (3, N'HZ-AQ1',  N'Jeddah-Cairo shuttle'),
    (3, N'HZ-AK24', N'High-density Hajj/Umrah B777-300ER'),
    -- Contract 4 (Nile Air)
    (4, N'SU-BQM',  N'CAI base narrowbody'),
    (4, N'SU-BQN',  N'High-capacity A321'),
    -- Contract 5 (Emirates)
    (5, N'A6-ENA',  N'DXB-CAI morning rotation'),
    (5, N'A6-EQP',  N'DXB-CAI evening rotation'),
    -- Contract 7 (Wizz Air)
    (7, N'HA-LVI',  N'Sphinx SPX European LCC link'),
    (7, N'HA-LVM',  N'Borg El Arab HBE LCC link'),
    -- Contract 8 (Smartwings)
    (8, N'OK-TVF',  N'Prague-Hurghada leisure rotation'),
    -- Contract 11 (Lufthansa)
    (11, N'D-AINZ', N'Frankfurt-Cairo daily service');
GO

-- 5.18 Contracted Ground Handling Services & GSE (48 rows)
INSERT INTO dbo.[Com_ContractServices]
    ([ContractID], [ServiceCode], [NegotiatedRateUSD], [EstMonthlyCommitmentUSD], [IsIncludedInSla], [SourceType])
VALUES
    (1,  N'GPU',      120.00, 14520.00, 1, N'AMENDMENT'),
    (1,  N'PUSH',     220.00, 26620.00, 1, N'BASE'),
    (1,  N'BAGGAGE',  240.00, 29040.00, 1, N'BASE'),
    (1,  N'CLEAN',    160.00, 19360.00, 1, N'BASE'),
    (1,  N'TOILET',    95.00, 11495.00, 1, N'AMENDMENT'),
    (1,  N'WATER',     75.00,  9075.00, 1, N'AMENDMENT'),
    (2,  N'GPU',      115.00,  7705.00, 1, N'BASE'),
    (2,  N'PUSH',     210.00, 14070.00, 1, N'BASE'),
    (2,  N'COBUS',    110.00,  7370.00, 1, N'BASE'),
    (2,  N'BAGGAGE',  230.00, 15410.00, 1, N'BASE'),
    (3,  N'GPU',      120.00,  8880.00, 1, N'BASE'),
    (3,  N'ACU',      150.00, 11100.00, 1, N'BASE'),
    (3,  N'PUSH',     220.00, 16280.00, 1, N'BASE'),
    (3,  N'AMBULIFT', 140.00, 10360.00, 1, N'BASE'),
    (4,  N'GPU',      120.00,  7080.00, 1, N'AMENDMENT'),
    (4,  N'ASU',      180.00, 10620.00, 1, N'AMENDMENT'),
    (4,  N'WATER',     75.00,  4425.00, 1, N'AMENDMENT'),
    (4,  N'STEPS',     85.00,  5015.00, 1, N'AMENDMENT'),
    (5,  N'GPU',      120.00,  9120.00, 1, N'BASE'),
    (5,  N'ACU',      150.00, 11400.00, 1, N'BASE'),
    (5,  N'PUSH',     220.00, 16720.00, 1, N'BASE'),
    (5,  N'CARGO_LD', 310.00, 23560.00, 1, N'BASE'),
    (5,  N'CLEAN',    160.00, 12160.00, 1, N'BASE'),
    (6,  N'GPU',      120.00,  6960.00, 1, N'BASE'),
    (6,  N'CARGO_LD', 310.00, 17980.00, 1, N'BASE'),
    (6,  N'PUSH',     220.00, 12760.00, 1, N'BASE'),
    (6,  N'SECURITY', 175.00, 10150.00, 1, N'BASE'),
    (7,  N'STEPS',     80.00,  4400.00, 1, N'BASE'),
    (7,  N'BAGGAGE',  220.00, 12100.00, 1, N'BASE'),
    (7,  N'DISPATCH', 125.00,  6875.00, 1, N'BASE'),
    (8,  N'COBUS',    110.00,  4400.00, 1, N'BASE'),
    (8,  N'STEPS',     85.00,  3400.00, 1, N'BASE'),
    (8,  N'WATER',     75.00,  3000.00, 1, N'BASE'),
    (8,  N'CLEAN',    160.00,  6400.00, 1, N'BASE'),
    (9,  N'COBUS',    110.00,  4840.00, 1, N'BASE'),
    (9,  N'GPU',      120.00,  5280.00, 1, N'BASE'),
    (9,  N'ACU',      150.00,  6600.00, 1, N'AMENDMENT'),
    (9,  N'CREW',      55.00,  2420.00, 1, N'AMENDMENT'),
    (10, N'CREW',      55.00,  1320.00, 1, N'BASE'),
    (10, N'SECURITY', 175.00,  4200.00, 1, N'BASE'),
    (10, N'GPU',      120.00,  2880.00, 1, N'BASE'),
    (11, N'GPU',      120.00,  6240.00, 1, N'BASE'),
    (11, N'PUSH',     220.00, 11440.00, 1, N'BASE'),
    (11, N'CLEAN',    160.00,  8320.00, 1, N'BASE'),
    (11, N'DISPATCH', 130.00,  6760.00, 1, N'BASE'),
    (12, N'COBUS',    110.00,  5060.00, 1, N'BASE'),
    (12, N'GPU',      120.00,  5520.00, 1, N'BASE'),
    (12, N'BAGGAGE',  240.00, 11040.00, 1, N'BASE');
GO

-- 5.19 Contract Version History (21 rows — active releases + locked archived versions)
SET IDENTITY_INSERT dbo.[Com_ContractVersions] ON;
INSERT INTO dbo.[Com_ContractVersions]
    ([ContractVersionID], [ContractID], [VersionLabel], [VersionStatus], [VersionDate], [IsLatestVersion], [IsLockedArchive], [AnnualValueSnapshotUSD], [VersionNotes], [CreatedByUserID])
VALUES
    (1,  1,  N'v1.0',           N'SUPERSEDED', '2026-01-01', 0, 1, 5748900.00, N'Base agreement before executed Hurghada amendment',                 1),
    (2,  1,  N'v1.1 (AMD)',     N'ACTIVE',     '2026-03-01', 1, 0, 5813700.00, N'Current active release incorporating Annex 1 HRG expansion',        2),
    (3,  2,  N'v1.0',           N'ACTIVE',     '2026-01-01', 1, 0, 2427400.00, N'Initial approved multi-station release',                            2),
    (4,  3,  N'v1.0',           N'ACTIVE',     '2026-01-01', 1, 0, 3491100.00, N'Initial approved Saudia SGHA release',                              2),
    (5,  4,  N'v1.0',           N'SUPERSEDED', '2026-01-01', 0, 1, 2104400.00, N'Base agreement before Sharm El Sheikh & water servicing addendum',  1),
    (6,  4,  N'v1.1 (AMD)',     N'ACTIVE',     '2026-04-15', 1, 0, 2154800.00, N'Active release following Annex A SSH & B788 expansion',             4),
    (7,  5,  N'v1.0',           N'SUPERSEDED', '2024-02-01', 0, 1, 3980000.00, N'Original 2024-2026 Emirates Cairo hub agreement',                   3),
    (8,  5,  N'v1.1',           N'SUPERSEDED', '2025-02-01', 0, 1, 4155096.00, N'Mid-term schedule frequency adjustment',                            3),
    (9,  5,  N'v2.0 (Renewed)', N'ACTIVE',     '2026-02-01', 1, 0, 4321300.00, N'2-year strategic renewal with +4.0% CPI indexation',                2),
    (10, 6,  N'v1.0',           N'ACTIVE',     '2026-01-15', 1, 0, 3044000.00, N'Active DHL Cargo Village main-deck handling contract',              2),
    (11, 7,  N'v1.0',           N'ACTIVE',     '2026-03-01', 1, 0, 2142000.00, N'Active Wizz Air SPX/HBE/HRG LCC handling release',                  4),
    (12, 8,  N'v1.0',           N'EXPIRING',   '2025-11-01', 1, 0, 1614000.00, N'Current release flagged within 30-day expiry window',               2),
    (13, 9,  N'v1.0',           N'SUPERSEDED', '2025-10-15', 0, 1, 1740000.00, N'Initial Sinai charter season release',                              3),
    (14, 9,  N'v1.1',           N'SUPERSEDED', '2026-01-10', 0, 1, 1796400.00, N'Winter peak frequency revision',                                    3),
    (15, 9,  N'v1.2 (AMD)',     N'RENEWAL',    '2026-06-01', 1, 0, 1850400.00, N'North Coast DBB summer addendum; renewal currently in progress',    2),
    (16, 10, N'v1.0',           N'EXPIRED',    '2025-01-01', 1, 0, 1462000.00, N'Concluded VIP ground escort term',                                  4),
    (17, 11, N'v0.9',           N'SUPERSEDED', '2026-10-20', 0, 1, 2410000.00, N'Initial pricing simulation draft',                                  1),
    (18, 11, N'v1.0',           N'PENDING',    '2026-10-28', 1, 0, 2481000.00, N'Submitted for Commercial Admin approval',                           1),
    (19, 12, N'v0.8',           N'SUPERSEDED', '2026-10-25', 0, 1, 1850000.00, N'Preliminary Red Sea slot worksheet',                                1),
    (20, 12, N'v0.9',           N'SUPERSEDED', '2026-10-28', 0, 1, 1885000.00, N'Updated widebody turnaround tariffs',                               1),
    (21, 12, N'v1.0',           N'DRAFT',      '2026-10-30', 1, 0, 1911000.00, N'Working draft in Contract Entry Studio',                            1);
SET IDENTITY_INSERT dbo.[Com_ContractVersions] OFF;
GO

-- 5.20 Contract Renewals (3 rows)
SET IDENTITY_INSERT dbo.[Com_ContractRenewals] ON;
INSERT INTO dbo.[Com_ContractRenewals]
    ([RenewalID], [ContractID], [PreviousContractRef], [GeneratedRenewalRef], [PreviousStartDate], [PreviousEndDate], [NewEffectiveDate], [NewExpiryDate], [ExtensionDurationYears], [InflationIndexationPct], [PreviousAnnualValueUSD], [UpdatedAnnualValueUSD], [ExecutionMode], [RenewalAddendumNotes], [RenewedByUserID], [RenewedAt])
VALUES
    (1, 5, N'TAS-CAI-2024-EK005',    N'TAS-CAI-2026-EK005',       '2024-02-01', '2026-01-31', '2026-02-01', '2028-01-31', 2, 4.00, 4155096.00, 4321300.00, N'DIRECT_APPLY',  N'2-year strategic widebody renewal approved with +4.0% standard CPI escalation.', 2, '2026-01-20T11:00:00'),
    (2, 9, N'TAS-SSH-2025-FZ102',    N'TAS-SSH-2025-FZ102-R1',    '2025-10-15', '2026-11-05', '2026-11-06', '2028-11-05', 2, 6.50, 1850400.00, 1970676.00, N'STUDIO_ADJUST', N'Opened in studio for fine-tuning peak winter Red Sea & Sphinx slots.',            3, '2026-10-24T14:30:00'),
    (3, 8, N'TAS-HRG-2025-QS088',    N'TAS-HRG-2025-QS088-R1',    '2025-11-01', '2026-11-12', '2026-11-13', '2027-11-12', 1, 2.50, 1614000.00, 1654350.00, N'STUDIO_ADJUST', N'1-year charter extension proposal staged for carrier signature.',                  1, '2026-10-29T16:15:00');
SET IDENTITY_INSERT dbo.[Com_ContractRenewals] OFF;
GO

-- 5.21 Executed Contract Amendments (3 rows)
SET IDENTITY_INSERT dbo.[Com_ContractAmendments] ON;
INSERT INTO dbo.[Com_ContractAmendments]
    ([AmendmentID], [ContractID], [AmendmentRef], [AmendmentTitle], [EffectiveDate], [CreatedDate], [MonthlySurchargeUSD], [PreviousAnnualValueUSD], [UpdatedAnnualValueUSD], [ResultingVersionLabel], [ClauseNotes], [CreatedByUserID])
VALUES
    (1, 1, N'TAS-CAI-2026-MS001-AMD-1', N'Annex 1: Hurghada Transit & Ramp Service Expansion',              '2026-03-01', '2026-02-15', 5400.00, 5748900.00, 5813700.00, N'v1.1 (AMD)', N'High season turnaround equipment, crew layover lodging and passenger stairs authorized for Red Sea operations.', 2),
    (2, 4, N'TAS-CAI-2026-NP004-AMD-1', N'Annex A: Sharm El Sheikh Station & Water Servicing Addendum',     '2026-04-15', '2026-04-01', 4200.00, 2104400.00, 2154800.00, N'v1.1 (AMD)', N'Potable water replenishment and widebody stairs addition for European charter arrivals.',                        4),
    (3, 9, N'TAS-SSH-2025-FZ102-AMD-1', N'Amendment #1: Al Alamein Summer Station & Crew Shuttle Addendum', '2026-06-01', '2026-05-20', 4500.00, 1796400.00, 1850400.00, N'v1.2 (AMD)', N'North Coast DBB summer station activation with crew van shuttle & cabin pre-cooling.',                           2);
SET IDENTITY_INSERT dbo.[Com_ContractAmendments] OFF;
GO

-- 5.22 Structured Amendment Amenities (3 rows — 1:1 with Com_ContractAmendments)
INSERT INTO dbo.[Com_AmendmentAmenities]
    ([AmendmentID], [CrewHousingEnabled], [HousingHotelTier], [HousingBoardType], [HousingRoomsAllocated], [HousingStationCode], [CrewTransportEnabled], [TransportVehicleType], [TransportRouteType], [PassengerLaddersEnabled], [LadderSpecification], [StairOperatorIncluded], [StairLightingIncluded], [PotableWaterEnabled], [WaterRefillCapacity], [WaterWhoCertificate], [WaterAntiBacterialFlush])
VALUES
    (1, 1, N'4-Star Airport Transit Hotel', N'BB',   8,    N'HRG', 1, N'VIP AC Crew Van (HiAce / Sprinter)',  N'Ramp <-> Terminal <-> Hotel (Roundtrip)', 1, N'Self-Propelled Motorized Stairs (Covered Canopy)', 1, 1, 1, N'Full Tank Replenishment per Sortie',    1, 1),
    (2, 0, NULL,                            NULL,    NULL, NULL,   1, N'Dedicated AC Shuttle Bus (30 Seats)', N'Airside Ramp <-> Terminal Only',          1, N'Self-Propelled Motorized Stairs (Covered Canopy)', 1, 1, 1, N'Heavy Widebody High Volume (2,000L+)', 1, 1),
    (3, 1, N'5-Star Luxury City Hotel',     N'HALF', 6,    N'DBB', 1, N'VIP AC Crew Van (HiAce / Sprinter)',  N'Ramp <-> Terminal <-> Hotel (Roundtrip)', 0, NULL,                                                0, 0, 1, N'Full Tank Replenishment per Sortie',    1, 1);
GO

-- 5.23 Amendment Appended Stations (3 rows)
INSERT INTO dbo.[Com_AmendmentStations] ([AmendmentID], [StationCode], [MonthlyStationFeeUSD])
VALUES
    (1, N'HRG', 1200.00),
    (2, N'SSH', 1200.00),
    (3, N'DBB', 1200.00);
GO

-- 5.24 Amendment Appended Fleet Models (3 rows)
INSERT INTO dbo.[Com_AmendmentFleetModels] ([AmendmentID], [ModelCode], [MonthlyFleetFeeUSD])
VALUES
    (1, N'A321', 750.00),
    (2, N'B788', 750.00),
    (3, N'B39M', 750.00);
GO

-- 5.25 Amendment Appended GSE Services (7 rows)
INSERT INTO dbo.[Com_AmendmentServices] ([AmendmentID], [ServiceCode], [MonthlyAddendumFeeUSD])
VALUES
    (1, N'GPU',    450.00),
    (1, N'TOILET', 400.00),
    (2, N'GPU',    450.00),
    (2, N'ASU',    550.00),
    (3, N'ACU',    600.00),
    (3, N'GPU',    450.00),
    (3, N'CLEAN',  350.00);
GO

-- 5.26 Governance & Approval Audit Log (15 rows)
SET IDENTITY_INSERT dbo.[Sec_ContractAuditLog] ON;
INSERT INTO dbo.[Sec_ContractAuditLog]
    ([AuditLogID], [ContractID], [ActionType], [PreviousStatus], [NewStatus], [VersionLabel], [ActionDetails], [PerformedByUserID], [PerformedAt])
VALUES
    (1,  1,  N'CREATE_CONTRACT',  NULL,       N'DRAFT',    N'v1.0',           N'Created base flag carrier agreement TAS-CAI-2026-MS001 in Contract Entry Studio.',      1, '2026-01-01T09:00:00'),
    (2,  1,  N'ADMIN_APPROVE',    N'DRAFT',   N'ACTIVE',   N'v1.0',           N'Commercial Admin approved and activated TAS-CAI-2026-MS001.',                           2, '2026-01-01T11:30:00'),
    (3,  1,  N'ADD_AMENDMENT',    N'ACTIVE',  N'ACTIVE',   N'v1.1 (AMD)',     N'Executed TAS-CAI-2026-MS001-AMD-1 (+$5,400/mo Hurghada & crew housing expansion).',     2, '2026-02-15T15:10:00'),
    (4,  2,  N'ADMIN_APPROVE',    N'DRAFT',   N'ACTIVE',   N'v1.0',           N'Approved Air Cairo 6-station scheduled handling contract.',                             2, '2026-01-02T10:15:00'),
    (5,  3,  N'ADMIN_APPROVE',    N'PENDING', N'ACTIVE',   N'v1.0',           N'Approved Saudia Airlines SGHA 2013 handling contract.',                                 2, '2026-01-03T13:45:00'),
    (6,  4,  N'ADD_AMENDMENT',    N'ACTIVE',  N'ACTIVE',   N'v1.1 (AMD)',     N'Executed TAS-CAI-2026-NP004-AMD-1 adding SSH station, B788 model & potable water.',     4, '2026-04-01T12:20:00'),
    (7,  5,  N'RENEW_CONTRACT',   N'RENEWAL', N'ACTIVE',   N'v2.0 (Renewed)', N'Applied 2-year renewal with +4.0% CPI indexation for Emirates Airline.',                2, '2026-01-20T11:05:00'),
    (8,  6,  N'ADMIN_APPROVE',    N'DRAFT',   N'ACTIVE',   N'v1.0',           N'Approved DHL Aviation main-deck cargo handling contract.',                              2, '2026-01-15T09:50:00'),
    (9,  7,  N'ADMIN_APPROVE',    N'PENDING', N'ACTIVE',   N'v1.0',           N'Approved Wizz Air LCC fast-turnaround agreement at SPX/HBE/HRG.',                       4, '2026-03-01T08:40:00'),
    (10, 8,  N'RENEW_CONTRACT',   N'EXPIRING',N'EXPIRING', N'v1.0',           N'Staged +1 year renewal quote TAS-HRG-2025-QS088-R1 for Smartwings.',                    1, '2026-10-29T16:16:00'),
    (11, 9,  N'ADD_AMENDMENT',    N'ACTIVE',  N'ACTIVE',   N'v1.2 (AMD)',     N'Executed Al Alamein (DBB) summer station & crew transport amendment.',                  2, '2026-05-20T14:00:00'),
    (12, 9,  N'RENEW_CONTRACT',   N'ACTIVE',  N'RENEWAL',  N'v1.2 (AMD)',     N'Transitioned TAS-SSH-2025-FZ102 into Renewal workflow (+2 yrs @ +6.5%).',               3, '2026-10-24T14:32:00'),
    (13, 11, N'CREATE_CONTRACT',  NULL,       N'DRAFT',    N'v0.9',           N'Created Lufthansa 2027 draft agreement.',                                               1, '2026-10-20T10:00:00'),
    (14, 11, N'SUBMIT_REVIEW',    N'DRAFT',   N'PENDING',  N'v1.0',           N'Submitted TAS-CAI-2027-LH118 for Commercial Admin approval.',                           1, '2026-10-28T17:00:00'),
    (15, 12, N'EDIT_RESET_DRAFT', N'DRAFT',   N'DRAFT',    N'v1.0',           N'Updated Condor widebody rates in studio; version incremented to v1.0 in Draft status.', 1, '2026-10-30T15:25:00');
SET IDENTITY_INSERT dbo.[Sec_ContractAuditLog] OFF;
GO

-- ============================================================================
-- SECTION 6: REPORTING VIEWS & WORKFLOW STORED PROCEDURES
-- Directly supports Contracts Registry Grid, KPI Cards, Approval & Renewals
-- ============================================================================

-- 6.1 View: Contracts Registry Summary (Powers Screen 1 Table & Active Period KPIs)
CREATE OR ALTER VIEW dbo.[vw_ContractsRegistrySummary]
AS
SELECT
    c.[ContractID],
    c.[ContractRef],
    c.[CustomerReference],
    c.[CustomerID],
    cust.[CustomerFullName]        AS [CustomerName],
    cust.[CarrierDisplayCode]      AS [CarrierCode],
    c.[CategoryCode],
    cat.[CategoryName],
    c.[ContractStatus],
    c.[CurrentVersionLabel],
    c.[PrimaryStationCode],
    st.[AirportName]               AS [PrimaryAirportName],
    c.[EffectiveFromDate],
    c.[ValidToDate],
    DATEDIFF(DAY, CAST(SYSUTCDATETIME() AS DATE), c.[ValidToDate]) AS [DaysRemaining],
    c.[CurrencyCode],
    c.[PaymentTermCode],
    pmt.[TermName]                 AS [PaymentTermName],
    c.[SghaStandardCode],
    sgha.[StandardFullName]        AS [SghaStandardName],
    c.[ApronPolicyCode],
    pol.[PolicyName]               AS [ApronPolicyName],
    c.[RegistrationScope],
    c.[MonthlyFlightVolume],
    (c.[MonthlyFlightVolume] * 12) AS [AnnualFlightVolume],
    c.[BaseNarrowRateUSD],
    c.[BaseWideRateUSD],
    c.[AnnualEscalationPct],
    c.[EstimatedMonthlyRevUSD],
    c.[AnnualContractValueUSD],
    c.[ProfitMarginPct],
    c.[CreatedDate],
    ISNULL(stAgg.[AuthorizedStationCount], 0)   AS [AuthorizedStationCount],
    ISNULL(stAgg.[AuthorizedStationsCSV], N'')  AS [AuthorizedStationsCSV],
    ISNULL(flAgg.[CoveredModelCount], 0)        AS [CoveredModelCount],
    ISNULL(flAgg.[CoveredModelsCSV], N'')       AS [CoveredModelsCSV],
    ISNULL(regAgg.[WhitelistedRegCount], 0)     AS [WhitelistedRegistrationsCount],
    ISNULL(regAgg.[WhitelistedRegsCSV], N'')    AS [WhitelistedRegistrationsCSV],
    ISNULL(amdAgg.[AmendmentCount], 0)          AS [ExecutedAmendmentCount]
FROM dbo.[Com_Contracts] c
INNER JOIN dbo.[Ar_AirlineCustomers]   cust ON cust.[CustomerID]      = c.[CustomerID]
INNER JOIN dbo.[Lkp_CarrierCategories] cat  ON cat.[CategoryCode]     = c.[CategoryCode]
INNER JOIN dbo.[Lkp_AirportStations]   st   ON st.[StationCode]       = c.[PrimaryStationCode]
INNER JOIN dbo.[Lkp_PaymentTerms]      pmt  ON pmt.[PaymentTermCode]  = c.[PaymentTermCode]
INNER JOIN dbo.[Lkp_SghaStandards]     sgha ON sgha.[SghaStandardCode]= c.[SghaStandardCode]
INNER JOIN dbo.[Lkp_ApronPolicies]     pol  ON pol.[ApronPolicyCode]  = c.[ApronPolicyCode]
OUTER APPLY (
    SELECT
        COUNT(*) AS [AuthorizedStationCount],
        STRING_AGG(cs.[StationCode], N', ') WITHIN GROUP (ORDER BY cs.[IsPrimaryHub] DESC, cs.[StationCode] ASC) AS [AuthorizedStationsCSV]
    FROM dbo.[Com_ContractStations] cs
    WHERE cs.[ContractID] = c.[ContractID]
) stAgg
OUTER APPLY (
    SELECT
        COUNT(*) AS [CoveredModelCount],
        STRING_AGG(cf.[ModelCode], N', ') WITHIN GROUP (ORDER BY cf.[ModelCode] ASC) AS [CoveredModelsCSV]
    FROM dbo.[Com_ContractFleetModels] cf
    WHERE cf.[ContractID] = c.[ContractID]
) flAgg
OUTER APPLY (
    SELECT
        COUNT(*) AS [WhitelistedRegCount],
        STRING_AGG(cr.[RegistrationNo], N', ') WITHIN GROUP (ORDER BY cr.[RegistrationNo] ASC) AS [WhitelistedRegsCSV]
    FROM dbo.[Com_ContractRegistrations] cr
    WHERE cr.[ContractID] = c.[ContractID]
) regAgg
OUTER APPLY (
    SELECT COUNT(*) AS [AmendmentCount]
    FROM dbo.[Com_ContractAmendments] ca
    WHERE ca.[ContractID] = c.[ContractID]
) amdAgg;
GO

-- 6.2 View: Contract Quick Audit Card (Powers Modal 2 Complete Overview)
CREATE OR ALTER VIEW dbo.[vw_ContractQuickAuditCard]
AS
SELECT
    v.*,
    c.[ConcessionRoyaltyPct],
    c.[TurnaroundDurationMins],
    c.[MtowTierCode],
    mt.[TierDisplayName]           AS [MtowTierName],
    c.[CommercialRemarks],
    uCreate.[FullName]             AS [CreatedByFullName],
    uApprove.[FullName]            AS [ApprovedByFullName],
    c.[ApprovedAt],
    ISNULL(srvAgg.[ContractedServiceCount], 0)  AS [ContractedServiceCount],
    ISNULL(srvAgg.[AuxiliaryMonthlyTotalUSD], 0) AS [AuxiliaryMonthlyTotalUSD]
FROM dbo.[vw_ContractsRegistrySummary] v
INNER JOIN dbo.[Com_Contracts] c       ON c.[ContractID]    = v.[ContractID]
INNER JOIN dbo.[Sec_Users]     uCreate ON uCreate.[UserID]  = c.[CreatedByUserID]
LEFT  JOIN dbo.[Sec_Users]     uApprove ON uApprove.[UserID]= c.[ApprovedByUserID]
LEFT  JOIN dbo.[Lkp_MtowTiers] mt      ON mt.[MtowTierCode] = c.[MtowTierCode]
OUTER APPLY (
    SELECT
        COUNT(*) AS [ContractedServiceCount],
        SUM(cs.[EstMonthlyCommitmentUSD]) AS [AuxiliaryMonthlyTotalUSD]
    FROM dbo.[Com_ContractServices] cs
    WHERE cs.[ContractID] = c.[ContractID]
) srvAgg;
GO

-- 6.3 Stored Procedure: Commercial Admin Approve & Activate Contract
CREATE OR ALTER PROCEDURE dbo.[usp_ApproveAndActivateContract]
    @ContractID       INT,
    @ApproverUserID   INT,
    @ApprovalNotes    NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @CanApprove BIT = 0;
    DECLARE @OldStatus  NVARCHAR(20);
    DECLARE @VerLabel   NVARCHAR(30);

    SELECT @CanApprove = r.[CanApproveAndActivate]
    FROM dbo.[Sec_Users] u
    INNER JOIN dbo.[Sec_Roles] r ON r.[RoleCode] = u.[RoleCode]
    WHERE u.[UserID] = @ApproverUserID AND u.[IsActive] = 1;

    IF ISNULL(@CanApprove, 0) = 0
    BEGIN
        THROW 50001, N'Permission denied: Only an active Commercial Admin can approve and activate contracts.', 1;
    END;

    SELECT @OldStatus = [ContractStatus], @VerLabel = [CurrentVersionLabel]
    FROM dbo.[Com_Contracts]
    WHERE [ContractID] = @ContractID;

    IF @OldStatus IS NULL
    BEGIN
        THROW 50002, N'Target contract was not found.', 1;
    END;

    BEGIN TRANSACTION;

    UPDATE dbo.[Com_Contracts]
    SET [ContractStatus]   = N'ACTIVE',
        [ApprovedByUserID] = @ApproverUserID,
        [ApprovedAt]       = SYSUTCDATETIME(),
        [UpdatedAt]        = SYSUTCDATETIME()
    WHERE [ContractID] = @ContractID;

    UPDATE dbo.[Com_ContractVersions]
    SET [VersionStatus] = N'ACTIVE',
        [VersionNotes]  = COALESCE(@ApprovalNotes, [VersionNotes])
    WHERE [ContractID] = @ContractID AND [IsLatestVersion] = 1;

    INSERT INTO dbo.[Sec_ContractAuditLog]
        ([ContractID], [ActionType], [PreviousStatus], [NewStatus], [VersionLabel], [ActionDetails], [PerformedByUserID])
    VALUES
        (@ContractID, N'ADMIN_APPROVE', @OldStatus, N'ACTIVE', @VerLabel,
         COALESCE(@ApprovalNotes, N'Approved and activated by Commercial Admin.'), @ApproverUserID);

    COMMIT TRANSACTION;
END;
GO

-- 6.4 Stored Procedure: Execute Contract Renewal (-R1 / -R2 & CPI Indexation)
CREATE OR ALTER PROCEDURE dbo.[usp_SaveContractRenewal]
    @ContractID              INT,
    @NewEffectiveDate        DATE,
    @NewExpiryDate           DATE,
    @ExtensionDurationYears  INT = NULL,
    @InflationIndexationPct  DECIMAL(5, 2) = 0.00,
    @RenewalNotes            NVARCHAR(500) = NULL,
    @RenewedByUserID         INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @NewExpiryDate <= @NewEffectiveDate
    BEGIN
        THROW 50010, N'Validation error: NewExpiryDate must be strictly after NewEffectiveDate.', 1;
    END;

    DECLARE @OldRef        NVARCHAR(50);
    DECLARE @NewRef        NVARCHAR(50);
    DECLARE @OldStart      DATE;
    DECLARE @OldEnd        DATE;
    DECLARE @OldVal        DECIMAL(15, 2);
    DECLARE @NewVal        DECIMAL(15, 2);
    DECLARE @OldStatus     NVARCHAR(20);
    DECLARE @NewVerLabel   NVARCHAR(30);

    SELECT
        @OldRef    = [ContractRef],
        @OldStart  = [EffectiveFromDate],
        @OldEnd    = [ValidToDate],
        @OldVal    = [AnnualContractValueUSD],
        @OldStatus = [ContractStatus]
    FROM dbo.[Com_Contracts]
    WHERE [ContractID] = @ContractID;

    IF @OldRef IS NULL
    BEGIN
        THROW 50011, N'Contract not found for renewal.', 1;
    END;

    IF CHARINDEX(N'-R', @OldRef) > 0
    BEGIN
        DECLARE @Pos INT = CHARINDEX(N'-R', @OldRef);
        DECLARE @BaseRef NVARCHAR(50) = LEFT(@OldRef, @Pos - 1);
        DECLARE @Seq INT = TRY_CAST(SUBSTRING(@OldRef, @Pos + 2, 10) AS INT);
        SET @NewRef = CONCAT(@BaseRef, N'-R', ISNULL(@Seq, 1) + 1);
    END
    ELSE
    BEGIN
        SET @NewRef = CONCAT(@OldRef, N'-R1');
    END;

    SET @NewVal = ROUND(@OldVal * (1.0 + (@InflationIndexationPct / 100.0)), 2);
    SET @NewVerLabel = N'v2.0 (Renewed)';

    BEGIN TRANSACTION;

    UPDATE dbo.[Com_ContractVersions]
    SET [IsLatestVersion] = 0,
        [IsLockedArchive] = 1,
        [VersionStatus]   = CASE WHEN [VersionStatus] = N'ACTIVE' THEN N'SUPERSEDED' ELSE [VersionStatus] END
    WHERE [ContractID] = @ContractID AND [IsLatestVersion] = 1;

    INSERT INTO dbo.[Com_ContractRenewals]
        ([ContractID], [PreviousContractRef], [GeneratedRenewalRef], [PreviousStartDate], [PreviousEndDate],
         [NewEffectiveDate], [NewExpiryDate], [ExtensionDurationYears], [InflationIndexationPct],
         [PreviousAnnualValueUSD], [UpdatedAnnualValueUSD], [ExecutionMode], [RenewalAddendumNotes], [RenewedByUserID])
    VALUES
        (@ContractID, @OldRef, @NewRef, @OldStart, @OldEnd,
         @NewEffectiveDate, @NewExpiryDate, @ExtensionDurationYears, @InflationIndexationPct,
         @OldVal, @NewVal, N'DIRECT_APPLY', @RenewalNotes, @RenewedByUserID);

    UPDATE dbo.[Com_Contracts]
    SET [ContractRef]            = @NewRef,
        [EffectiveFromDate]      = @NewEffectiveDate,
        [ValidToDate]            = @NewExpiryDate,
        [AnnualContractValueUSD] = @NewVal,
        [EstimatedMonthlyRevUSD] = ROUND(@NewVal / 12.0, 2),
        [ContractStatus]         = N'ACTIVE',
        [CurrentVersionLabel]    = @NewVerLabel,
        [CommercialRemarks]      = COALESCE(@RenewalNotes, [CommercialRemarks]),
        [UpdatedAt]              = SYSUTCDATETIME()
    WHERE [ContractID] = @ContractID;

    INSERT INTO dbo.[Com_ContractVersions]
        ([ContractID], [VersionLabel], [VersionStatus], [VersionDate], [IsLatestVersion], [IsLockedArchive], [AnnualValueSnapshotUSD], [VersionNotes], [CreatedByUserID])
    VALUES
        (@ContractID, @NewVerLabel, N'ACTIVE', CAST(SYSUTCDATETIME() AS DATE), 1, 0, @NewVal,
         COALESCE(@RenewalNotes, N'Renewed contract release'), @RenewedByUserID);

    INSERT INTO dbo.[Sec_ContractAuditLog]
        ([ContractID], [ActionType], [PreviousStatus], [NewStatus], [VersionLabel], [ActionDetails], [PerformedByUserID])
    VALUES
        (@ContractID, N'RENEW_CONTRACT', @OldStatus, N'ACTIVE', @NewVerLabel,
         CONCAT(N'Renewed agreement as ', @NewRef, N' until ', CONVERT(NVARCHAR(10), @NewExpiryDate, 120)), @RenewedByUserID);

    COMMIT TRANSACTION;
END;
GO

-- ============================================================================
-- SECTION 7: DEPLOYMENT VERIFICATION SUMMARY
-- ============================================================================
SELECT
    DB_NAME() AS [DatabaseName],
    (SELECT COUNT(*) FROM sys.tables WHERE is_ms_shipped = 0) AS [TotalTablesCreated],
    (SELECT COUNT(*) FROM sys.foreign_keys) AS [TotalEnforcedForeignKeys],
    (SELECT COUNT(*) FROM dbo.[Com_Contracts]) AS [SeededContractsCount],
    (SELECT COUNT(*) FROM dbo.[Flt_AircraftRegistrations]) AS [SeededRegistrationsCount];
GO
