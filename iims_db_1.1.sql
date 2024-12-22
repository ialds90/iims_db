-- Revised MySQL Database Schema with Improvements

-- 1. Audit Table for Reusable Audit Columns
CREATE TABLE AuditColumns (
    added_by INT,
    added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_by INT,
    updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (added_by) REFERENCES Users (user_id),
    FOREIGN KEY (updated_by) REFERENCES Users (user_id)
);

-- 2. User Management
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE COMMENT 'Login username',
    password_hash VARCHAR(255) NOT NULL COMMENT 'Hashed password',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT 'User email address',
    role_id INT COMMENT 'User role reference',
    site_id INT COMMENT 'Site reference',
    FOREIGN KEY (role_id) REFERENCES UserRoles(role_id),
    FOREIGN KEY (site_id) REFERENCES Sites(site_id)
) ENGINE=InnoDB COMMENT='Stores user information';

CREATE TABLE UserRoles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL COMMENT 'Role name'
) ENGINE=InnoDB COMMENT='Stores user roles';

CREATE TABLE AuthenticationLogs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL COMMENT 'Reference to Users',
    login_timestamp DATETIME NOT NULL COMMENT 'Login time',
    logout_timestamp DATETIME COMMENT 'Logout time',
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
) ENGINE=InnoDB COMMENT='Tracks user authentication events';

-- 3. Sites
CREATE TABLE Sites (
    site_id INT AUTO_INCREMENT PRIMARY KEY,
    site_name VARCHAR(100) NOT NULL COMMENT 'Name of the site',
    site_location VARCHAR(255) COMMENT 'Location of the site'
) ENGINE=InnoDB COMMENT='Stores site information';

-- 4. Asset Management
CREATE TABLE Assets (
    asset_id INT AUTO_INCREMENT PRIMARY KEY,
    asset_type_id INT COMMENT 'Reference to AssetTypes',
    make VARCHAR(100) COMMENT 'Asset make',
    model VARCHAR(100) COMMENT 'Asset model',
    serial_number VARCHAR(100) UNIQUE COMMENT 'Serial number',
    procurement_date DATE COMMENT 'Date of procurement',
    price DECIMAL(10, 2) COMMENT 'Asset price',
    vendor_id INT COMMENT 'Reference to Vendors',
    warranty_start_date DATE COMMENT 'Warranty start date',
    warranty_end_date DATE COMMENT 'Warranty end date',
    status_id INT COMMENT 'Reference to AssetStatus',
    current_site_id INT COMMENT 'Reference to Sites',
    assigned_to_user_id INT COMMENT 'Reference to Users',
    FOREIGN KEY (asset_type_id) REFERENCES AssetTypes(asset_type_id),
    FOREIGN KEY (vendor_id) REFERENCES Vendors(vendor_id),
    FOREIGN KEY (status_id) REFERENCES AssetStatus(status_id),
    FOREIGN KEY (current_site_id) REFERENCES Sites(site_id),
    FOREIGN KEY (assigned_to_user_id) REFERENCES Users(user_id)
) ENGINE=InnoDB COMMENT='Stores asset details';

CREATE TABLE AssetTypes (
    asset_type_id INT AUTO_INCREMENT PRIMARY KEY,
    asset_type_name VARCHAR(50) NOT NULL COMMENT 'Type of asset'
) ENGINE=InnoDB COMMENT='Defines types of assets';

CREATE TABLE AssetStatus (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL COMMENT 'Status of the asset'
) ENGINE=InnoDB COMMENT='Defines asset status types';

CREATE TABLE AssetHistory (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    asset_id INT COMMENT 'Reference to Assets',
    from_site_id INT COMMENT 'Previous site',
    to_site_id INT COMMENT 'New site',
    change_date DATETIME NOT NULL COMMENT 'Date of change',
    remarks TEXT COMMENT 'Remarks for the change',
    FOREIGN KEY (asset_id) REFERENCES Assets(asset_id),
    FOREIGN KEY (from_site_id) REFERENCES Sites(site_id),
    FOREIGN KEY (to_site_id) REFERENCES Sites(site_id)
) ENGINE=InnoDB COMMENT='Tracks asset movements';

-- 5. Procurement Management
CREATE TABLE ProcurementRequests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    requester_id INT COMMENT 'Reference to Users',
    asset_type_id INT COMMENT 'Reference to AssetTypes',
    request_date DATE NOT NULL COMMENT 'Request date',
    approval_status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending' COMMENT 'Approval status',
    approved_by_user_id INT COMMENT 'Reference to Users',
    approval_date DATE COMMENT 'Approval date',
    FOREIGN KEY (requester_id) REFERENCES Users(user_id),
    FOREIGN KEY (asset_type_id) REFERENCES AssetTypes(asset_type_id),
    FOREIGN KEY (approved_by_user_id) REFERENCES Users(user_id)
) ENGINE=InnoDB COMMENT='Manages procurement requests';

CREATE TABLE PurchaseOrders (
    po_id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_id INT COMMENT 'Reference to Vendors',
    request_id INT COMMENT 'Reference to ProcurementRequests',
    order_date DATE NOT NULL COMMENT 'Order date',
    delivery_date DATE COMMENT 'Delivery date',
    total_cost DECIMAL(10, 2) COMMENT 'Total order cost',
    terms TEXT COMMENT 'Terms of the order',
    FOREIGN KEY (vendor_id) REFERENCES Vendors(vendor_id),
    FOREIGN KEY (request_id) REFERENCES ProcurementRequests(request_id)
) ENGINE=InnoDB COMMENT='Manages purchase orders';

CREATE TABLE Vendors (
    vendor_id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_name VARCHAR(100) NOT NULL COMMENT 'Vendor name',
    contact_email VARCHAR(100) COMMENT 'Vendor contact email',
    contact_phone VARCHAR(20) COMMENT 'Vendor contact phone',
    rating DECIMAL(2, 1) COMMENT 'Vendor rating'
) ENGINE=InnoDB COMMENT='Stores vendor details';

-- 6. Repairs and Maintenance
CREATE TABLE Repairs (
    repair_id INT AUTO_INCREMENT PRIMARY KEY,
    asset_id INT COMMENT 'Reference to Assets',
    repair_status ENUM('Pending', 'In Progress', 'Completed') DEFAULT 'Pending' COMMENT 'Repair status',
    assigned_to_technician_id INT COMMENT 'Technician handling the repair',
    repair_start_date DATE COMMENT 'Start date of the repair',
    repair_completion_date DATE COMMENT 'Completion date of the repair',
    repair_cost DECIMAL(10, 2) COMMENT 'Cost of the repair',
    parts_used TEXT COMMENT 'Parts used during repair',
    FOREIGN KEY (asset_id) REFERENCES Assets(asset_id),
    FOREIGN KEY (assigned_to_technician_id) REFERENCES Users(user_id)
) ENGINE=InnoDB COMMENT='Tracks repair information';

CREATE TABLE MaintenanceSchedules (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    asset_id INT COMMENT 'Reference to Assets',
    scheduled_date DATE NOT NULL COMMENT 'Scheduled maintenance date',
    completed_date DATE COMMENT 'Completion date',
    assigned_to_technician_id INT COMMENT 'Technician handling the maintenance',
    notes TEXT COMMENT 'Maintenance notes',
    cost DECIMAL(10, 2) COMMENT 'Maintenance cost',
    FOREIGN KEY (asset_id) REFERENCES Assets(asset_id),
    FOREIGN KEY (assigned_to_technician_id) REFERENCES Users(user_id)
) ENGINE=InnoDB COMMENT='Schedules and tracks maintenance';

-- 7. Notifications
CREATE TABLE Notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    recipient_id INT COMMENT 'User receiving the notification',
    message TEXT NOT NULL COMMENT 'Notification message',
    notification_type ENUM('Repair', 'Maintenance', 'Warranty', 'General') COMMENT 'Type of notification',
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Notification timestamp',
    read_status BOOLEAN DEFAULT FALSE COMMENT 'Read status',
    FOREIGN KEY (recipient_id) REFERENCES Users(user_id)
) ENGINE=InnoDB COMMENT='Manages notifications';

-- 8. Reports and Analytics
CREATE TABLE Reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    report_type VARCHAR(50) NOT NULL COMMENT 'Type of report',
    generated_by INT COMMENT 'User who generated the report',
    generated_date DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Date generated',
    exported_format ENUM('PDF', 'Excel', 'CSV') COMMENT 'Export format',
    FOREIGN KEY (generated_by) REFERENCES Users(user_id)
) ENGINE=InnoDB COMMENT='Tracks report generation and exports';
