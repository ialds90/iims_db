CREATE TABLE Office_Types_TB (
    office_type_id INT AUTO_INCREMENT PRIMARY KEY,
    office_type_name VARCHAR(50) NOT NULL UNIQUE COMMENT 'Type of office, e.g., Head Office, Regional, Manager, Work Site',
    added_by INT NOT NULL COMMENT 'User who added this record',
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was added',
    updated_by INT COMMENT 'User who last updated this record',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    FOREIGN KEY (added_by) REFERENCES Users_TB(user_id),
    FOREIGN KEY (updated_by) REFERENCES Users_TB(user_id)
) ENGINE = InnoDB COMMENT = 'Stores office types for extensibility';

CREATE TABLE Offices_TB (
    office_id INT AUTO_INCREMENT PRIMARY KEY,
    parent_office_id INT NULL COMMENT 'References parent office for hierarchy',
    office_name VARCHAR(100) NOT NULL COMMENT 'Name of the office',
    office_type_id INT NOT NULL COMMENT 'References the type of office',
    added_by INT NOT NULL COMMENT 'User who added this record',
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was added',
    updated_by INT COMMENT 'User who last updated this record',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    FOREIGN KEY (parent_office_id) REFERENCES Offices_TB(office_id),
    FOREIGN KEY (office_type_id) REFERENCES Office_Types_TB(office_type_id),
    FOREIGN KEY (added_by) REFERENCES Users_TB(user_id),
    FOREIGN KEY (updated_by) REFERENCES Users_TB(user_id),
    INDEX idx_office_type (office_type_id)
) ENGINE = InnoDB COMMENT = 'Stores office hierarchy and details';

CREATE TABLE Departments_TB (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    office_id INT NOT NULL COMMENT 'References the office this department belongs to',
    department_name VARCHAR(100) NOT NULL COMMENT 'Name of the department',
    added_by INT NOT NULL COMMENT 'User who added this record',
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was added',
    updated_by INT COMMENT 'User who last updated this record',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    FOREIGN KEY (office_id) REFERENCES Offices_TB(office_id),
    FOREIGN KEY (added_by) REFERENCES Users_TB(user_id),
    FOREIGN KEY (updated_by) REFERENCES Users_TB(user_id)
) ENGINE = InnoDB COMMENT = 'Stores department information';

CREATE TABLE IT_Items_TB (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    brand VARCHAR(100) NOT NULL COMMENT 'Brand of the IT item',
    model VARCHAR(100) NOT NULL COMMENT 'Model of the IT item',
    serial_no VARCHAR(100) UNIQUE NOT NULL COMMENT 'Serial number of the IT item',
    device_name VARCHAR(100) COMMENT 'Device name',
    ip_address VARCHAR(15) COMMENT 'IP address of the device',
    processor VARCHAR(100) COMMENT 'Processor details',
    storage VARCHAR(100) COMMENT 'Storage details',
    purchase_date DATE COMMENT 'Purchase date',
    warranty_end_date DATE COMMENT 'Warranty end date',
    current_department_id INT NOT NULL COMMENT 'Current department this item is assigned to',
    added_by INT NOT NULL COMMENT 'User who added this record',
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was added',
    updated_by INT COMMENT 'User who last updated this record',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    FOREIGN KEY (current_department_id) REFERENCES Departments_TB(department_id),
    FOREIGN KEY (added_by) REFERENCES Users_TB(user_id),
    FOREIGN KEY (updated_by) REFERENCES Users_TB(user_id),
    INDEX idx_serial_no (serial_no)
) ENGINE = InnoDB COMMENT = 'Stores IT item details';

CREATE TABLE Peripheral_TB (
    peripheral_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL COMMENT 'References the parent IT item',
    type ENUM('Monitor', 'Keyboard', 'Mouse', 'Other') NOT NULL COMMENT 'Type of peripheral',
    serial_no VARCHAR(100) UNIQUE NOT NULL COMMENT 'Serial number of the peripheral',
    warranty_end_date DATE COMMENT 'Warranty end date',
    added_by INT NOT NULL COMMENT 'User who added this record',
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was added',
    updated_by INT COMMENT 'User who last updated this record',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    FOREIGN KEY (item_id) REFERENCES IT_Items_TB(item_id),
    FOREIGN KEY (added_by) REFERENCES Users_TB(user_id),
    FOREIGN KEY (updated_by) REFERENCES Users_TB(user_id),
    INDEX idx_peripheral_serial_no (serial_no)
) ENGINE = InnoDB COMMENT = 'Stores peripheral details linked to IT items';

CREATE TABLE Movement_History_TB (
    movement_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL COMMENT 'References the moved IT item',
    from_department_id INT NOT NULL COMMENT 'Department the item was moved from',
    to_department_id INT NOT NULL COMMENT 'Department the item was moved to',
    approved_by_user_id INT NOT NULL COMMENT 'User who approved the movement',
    reason TEXT COMMENT 'Reason for the movement',
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of the movement',
    added_by INT NOT NULL COMMENT 'User who added this record',
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was added',
    updated_by INT COMMENT 'User who last updated this record',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    FOREIGN KEY (item_id) REFERENCES IT_Items_TB(item_id),
    FOREIGN KEY (from_department_id) REFERENCES Departments_TB(department_id),
    FOREIGN KEY (to_department_id) REFERENCES Departments_TB(department_id),
    FOREIGN KEY (approved_by_user_id) REFERENCES Users_TB(user_id),
    FOREIGN KEY (added_by) REFERENCES Users_TB(user_id),
    FOREIGN KEY (updated_by) REFERENCES Users_TB(user_id)
) ENGINE = InnoDB COMMENT = 'Tracks movement history of IT items';

CREATE TABLE Repairs_Maintenance_TB (
    repair_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL COMMENT 'References the repaired IT item',
    description TEXT COMMENT 'Details of the repair or maintenance',
    cost DECIMAL(10, 2) COMMENT 'Cost of the repair or maintenance',
    performed_by VARCHAR(100) COMMENT 'Who performed the repair',
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of the repair',
    next_scheduled_maintenance DATE COMMENT 'Next scheduled maintenance date',
    added_by INT NOT NULL COMMENT 'User who added this record',
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was added',
    updated_by INT COMMENT 'User who last updated this record',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    FOREIGN KEY (item_id) REFERENCES IT_Items_TB(item_id),
    FOREIGN KEY (added_by) REFERENCES Users_TB(user_id),
    FOREIGN KEY (updated_by) REFERENCES Users_TB(user_id)
) ENGINE = InnoDB COMMENT = 'Tracks repairs and maintenance for IT items';

CREATE TABLE Software_Licenses_TB (
    license_id INT AUTO_INCREMENT PRIMARY KEY,
    license_key VARCHAR(255) UNIQUE NOT NULL COMMENT 'License key',
    software_name VARCHAR(100) NOT NULL COMMENT 'Name of the software',
    valid_until DATE COMMENT 'License expiration date',
    added_by INT NOT NULL COMMENT 'User who added this record',
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was added',
    updated_by INT COMMENT 'User who last updated this record',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    FOREIGN KEY (added_by) REFERENCES Users_TB(user_id),
    FOREIGN KEY (updated_by) REFERENCES Users_TB(user_id)
) ENGINE = InnoDB COMMENT = 'Stores software and license information';

CREATE TABLE License_Assignment_TB (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    license_id INT NOT NULL COMMENT 'References the software license',
    item_id INT NOT NULL COMMENT 'References the IT item assigned',
    assigned_by INT NOT NULL COMMENT 'User who assigned the license',
    assigned_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of the assignment',
    added_by INT NOT NULL COMMENT 'User who added this record',
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was added',
    updated_by INT COMMENT 'User who last updated this record',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    FOREIGN KEY (license_id) REFERENCES Software_Licenses_TB(license_id),
    FOREIGN KEY (item_id) REFERENCES IT_Items_TB(item_id),
    FOREIGN KEY (added_by) REFERENCES Users_TB(user_id),
    FOREIGN KEY (updated_by) REFERENCES Users_TB(user_id)
) ENGINE = InnoDB COMMENT = 'Tracks assignment of software licenses to IT items';
