
use Hospital_Analytics;

-- deparment table
CREATE TABLE Department (
    DepartmentID    INT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    DepartmentName  VARCHAR(100) NOT NULL UNIQUE,
    Location        VARCHAR(150) NOT NULL,
    PhoneExtension  VARCHAR(10)  NOT NULL UNIQUE
);

-- patient table
 CREATE TABLE Patient (
    PatientID             INT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    FirstName             VARCHAR(50)  NOT NULL,
    LastName              VARCHAR(50)  NOT NULL,
    DateOfBirth           DATE         NOT NULL,
    Gender                VARCHAR(10)  NOT NULL CHECK (Gender IN ('Male','Female','Other')),
    Address               VARCHAR(255),
    PhoneNumber           VARCHAR(15)  NOT NULL UNIQUE,
    Email                 VARCHAR(100) NOT NULL UNIQUE,
    EmergencyContactName  VARCHAR(100),
    EmergencyContactPhone VARCHAR(15)  
);

-- doctor table
CREATE TABLE Doctor (
    DoctorID       INT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    FirstName      VARCHAR(50)  NOT NULL,
    LastName       VARCHAR(50)  NOT NULL,
    Specialization VARCHAR(100) NOT NULL,
    PhoneNumber    VARCHAR(15)  NOT NULL UNIQUE,
    Email          VARCHAR(100) NOT NULL UNIQUE,
    DepartmentID   INT          NOT NULL FOREIGN KEY REFERENCES Department(DepartmentID),
    Availability   VARCHAR(20)  NOT NULL DEFAULT 'Available'
                                CHECK (Availability IN ('Available','On Leave','Busy'))
);

-- appointment table
CREATE TABLE Appointment (
    AppointmentID   INT         NOT NULL IDENTITY(1,1) PRIMARY KEY,
    PatientID       INT         NOT NULL FOREIGN KEY REFERENCES Patient(PatientID),
    DoctorID        INT         NOT NULL FOREIGN KEY REFERENCES Doctor(DoctorID),
    DepartmentID    INT         NOT NULL FOREIGN KEY REFERENCES Department(DepartmentID),
    AppointmentDate DATE        NOT NULL,
    AppointmentTime TIME        NOT NULL,
    Status          VARCHAR(20) NOT NULL DEFAULT 'Scheduled'
                                CHECK (Status IN ('Scheduled','Completed','Cancelled'))
);


-- medical records table
CREATE TABLE MedicalRecord (
    RecordID      INT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    PatientID     INT          NOT NULL FOREIGN KEY REFERENCES Patient(PatientID),
    DoctorID      INT          NOT NULL FOREIGN KEY REFERENCES Doctor(DoctorID),
    VisitDate     DATE         NOT NULL,
    Diagnosis     VARCHAR(MAX) NOT NULL,
    TreatmentPlan VARCHAR(MAX) ,
    Prescription  VARCHAR(MAX) 
);

-- medicine table
CREATE TABLE Medicine (
    MedicineID    INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    MedicineName  VARCHAR(150)   NOT NULL UNIQUE,
    Manufacturer  VARCHAR(150)   NOT NULL,
    StockQuantity INT            NOT NULL DEFAULT 0 CHECK (StockQuantity >= 0),
    Price         DECIMAL(10,2)  NOT NULL CHECK (Price >= 0)
);

-- prescription table
CREATE TABLE Prescription (
    PrescriptionID INT         NOT NULL IDENTITY(1,1) PRIMARY KEY,
    RecordID       INT         NOT NULL FOREIGN KEY REFERENCES MedicalRecord(RecordID),
    MedicineID     INT         NOT NULL FOREIGN KEY REFERENCES Medicine(MedicineID),
    Dosage         VARCHAR(50) NOT NULL,
    Frequency      VARCHAR(50) NOT NULL,
    Duration       VARCHAR(50) NOT NULL
);


-- billing table
CREATE TABLE Billing (
    BillingID     INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    PatientID     INT           NOT NULL FOREIGN KEY REFERENCES Patient(PatientID),
    TotalAmount   DECIMAL(10,2) NOT NULL CHECK (TotalAmount >= 0),
    PaymentStatus VARCHAR(10)   NOT NULL DEFAULT 'Unpaid'
                                CHECK (PaymentStatus IN ('Paid','Unpaid','Partial')),
    PaymentDate   DATE          NULL,
    PaymentMethod VARCHAR(20)   NULL
                                CHECK (PaymentMethod IN ('Cash','Credit Card','Debit Card','Insurance','Online'))
);

-- staff table
CREATE TABLE Staff (
    StaffID      INT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    FirstName    VARCHAR(50)  NOT NULL,
    LastName     VARCHAR(50)  NOT NULL,
    Role         VARCHAR(100) NOT NULL,
    DepartmentID INT          NOT NULL FOREIGN KEY REFERENCES Department(DepartmentID),
    PhoneNumber  VARCHAR(15)  NOT NULL UNIQUE,
    Email        VARCHAR(100) NOT NULL UNIQUE,
    ShiftHours   VARCHAR(50)  NULL
);

-- room table
CREATE TABLE Room (
    RoomID             INT         NOT NULL IDENTITY(1,1) PRIMARY KEY,
    RoomNumber         VARCHAR(10) NOT NULL UNIQUE,
    DepartmentID       INT         NOT NULL FOREIGN KEY REFERENCES Department(DepartmentID),
    RoomType           VARCHAR(20) NOT NULL
                                   CHECK (RoomType IN ('General','Private','ICU','Emergency','Surgery')),
    AvailabilityStatus VARCHAR(20) NOT NULL DEFAULT 'Available'
                                   CHECK (AvailabilityStatus IN ('Available','Occupied','Under Maintenance'))
);

-- room assignment table
CREATE TABLE RoomAssignment (
    AssignmentID  INT  NOT NULL IDENTITY(1,1) PRIMARY KEY,
    RoomID        INT  NOT NULL FOREIGN KEY REFERENCES Room(RoomID),
    PatientID     INT  NOT NULL FOREIGN KEY REFERENCES Patient(PatientID),
    AdmissionDate DATE NOT NULL,
    DischargeDate DATE NULL,
    CHECK (DischargeDate IS NULL OR DischargeDate >= AdmissionDate)  -- để ở dưới
);
