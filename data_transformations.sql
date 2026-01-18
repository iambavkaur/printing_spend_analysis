CREATE TABLE dbo.PrintingSpendRawData (
    EntityName        NVARCHAR(200),
    BannerName        NVARCHAR(200),
    Address           NVARCHAR(300),
    PrinterModel      NVARCHAR(100),
    SerialNo          NVARCHAR(100),
    CopyCharge        DECIMAL(12,4),
    PrevDateRaw       DATE,
    PrevReadRaw       INT,
    CurrDateRaw       DATE,
    CurrReadRaw       INT,
    InvoiceNumber     NVARCHAR(100),
    SubTotalAmount    DECIMAL(12,2),
    InvoiceAmountBase DECIMAL(12,2),
    GST               DECIMAL(12,2),
    QST               DECIMAL(12,2),
    PST               DECIMAL(12,2),
    HST               DECIMAL(12,2),
    InvoiceTotal      DECIMAL(12,2),
    InvoiceDate       DATE
);


ALTER TABLE dbo.PrintingSpendRawData
ADD
    BannerType      NVARCHAR(100),
    Department      NVARCHAR(100),
    PrinterType     NVARCHAR(100),
    PreviousDate    DATE,
    PreviousRead    INT,
    CurrentDate     DATE,
    CurrentRead     INT,
    AnnualVolume    INT,
    NegativeVolume  NVARCHAR(10),
    CostPerCopy     DECIMAL(10,4),
    PageType        NVARCHAR(50),
    Cost            DECIMAL(12,2);




INSERT INTO dbo.PrintingSpendRawData (
    EntityName,
    BannerName,
    Address,
    PrinterModel,
    SerialNo,
    CopyCharge,
    PrevDateRaw,
    PrevReadRaw,
    CurrDateRaw,
    CurrReadRaw,
    InvoiceNumber,
    SubTotalAmount,
    InvoiceAmountBase,
    GST, QST, PST, HST,
    InvoiceTotal,
    InvoiceDate,

    -- Derived columns
    BannerType,
    Department,
    PrinterType,
    PreviousDate,
    PreviousRead,
    CurrentDate,
    CurrentRead,
    AnnualVolume,
    NegativeVolume,
    CostPerCopy,
    PageType,
    Cost
)
SELECT
    EntityName,
    BannerName,
    Address,
    PrinterModel,
    SerialNo,
    CopyCharge,
    PrevDateRaw,
    PrevReadRaw,
    CurrDateRaw,
    CurrReadRaw,
    InvoiceNumber,
    SubTotalAmount,
    InvoiceAmountBase,
    GST, QST, PST, HST,
    InvoiceTotal,
    InvoiceDate,

    /* ---------------- DERIVATIONS ---------------- */

    -- Banner Type (text before dash)
    LEFT(BannerName, CHARINDEX('-', BannerName + '-') - 1) AS BannerType,

    -- Department (text after comma in Address)
    LTRIM(SUBSTRING(Address, CHARINDEX(',', Address) + 1, 200)) AS Department,

    -- Printer Type
    CASE
        WHEN PrinterModel LIKE 'MPC%' THEN 'MULTI-FUNCTION'
        WHEN PrinterModel LIKE 'SPC%' THEN 'MULTI-FUNCTION'
        ELSE 'ONLY B&W'
    END AS PrinterType,

    -- Dates & Reads
    PrevDateRaw  AS PreviousDate,
    PrevReadRaw  AS PreviousRead,
    CurrDateRaw  AS CurrentDate,
    CurrReadRaw  AS CurrentRead,

    -- Annual Volume
    (CurrReadRaw - PrevReadRaw) AS AnnualVolume,

    -- Negative Volume flag
    CASE
        WHEN (CurrReadRaw - PrevReadRaw) < 0 THEN 'Yes'
        ELSE 'No'
    END AS NegativeVolume,

    -- Cost per Copy
    CASE
        WHEN (CurrReadRaw - PrevReadRaw) > 0
            THEN SubTotalAmount / (CurrReadRaw - PrevReadRaw)
        ELSE 0
    END AS CostPerCopy,

    -- Page Type
    CASE
        WHEN PrinterModel LIKE '%C%' THEN 'COLOR'
        ELSE 'B&W'
    END AS PageType,

    -- Cost
    SubTotalAmount AS Cost
FROM dbo.PrintingSpendRawData;
