-- Revised MySQL Database Schema with Improvements
-- 1. User Management
CREATE TABLE
    Users_TB (
        user_id INT AUTO_INCREMENT PRIMARY KEY,
        login_username VARCHAR(50) NOT NULL UNIQUE COMMENT 'Login username',
        user_password_hash VARCHAR(255) NOT NULL COMMENT 'Hashed password',
        user_email VARCHAR(100) NOT NULL UNIQUE COMMENT 'User email address',
        user_role_id INT COMMENT 'User role reference',
        site_id INT COMMENT 'Site reference',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_role_id) REFERENCES UserRoles_TB (role_id),
        FOREIGN KEY (site_id) REFERENCES Sites_TB (site_id)
    ) ENGINE = InnoDB COMMENT = 'Stores user information';

CREATE TABLE
    UserRoles_TB (
        role_id INT AUTO_INCREMENT PRIMARY KEY,
        role_name VARCHAR(50) NOT NULL COMMENT 'Role name',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE = InnoDB COMMENT = 'Stores user roles';

CREATE TABLE
    AuthenticationLogs_TB (
        log_id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL COMMENT 'Reference to Users',
        login_timestamp DATETIME NOT NULL COMMENT 'Login time',
        logout_timestamp DATETIME COMMENT 'Logout time',
        FOREIGN KEY (user_id) REFERENCES Users_TB (user_id)
    ) ENGINE = InnoDB COMMENT = 'Tracks user authentication events';

-- 2. Sites
CREATE TABLE
    Sites_TB (
        site_id INT AUTO_INCREMENT PRIMARY KEY,
        site_name VARCHAR(100) NOT NULL COMMENT 'Name of the site',
        site_location VARCHAR(255) COMMENT 'Location of the site',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE = InnoDB COMMENT = 'Stores site information';

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


-- 3. Asset Management
CREATE TABLE
    AssetTypes_TB (
        asset_type_id INT AUTO_INCREMENT PRIMARY KEY,
        asset_type_name VARCHAR(50) NOT NULL COMMENT 'Type of asset',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE = InnoDB COMMENT = 'Defines types of assets';

CREATE TABLE
    AssetStatus_TB (
        status_id INT AUTO_INCREMENT PRIMARY KEY,
        status_name VARCHAR(50) NOT NULL COMMENT 'Status of the asset',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE = InnoDB COMMENT = 'Defines asset status types';

CREATE TABLE
    AssetConditions_TB (
        asset_condition_id INT AUTO_INCREMENT PRIMARY KEY,
        asset_condition_name VARCHAR(50) NOT NULL COMMENT 'Condition of the asset',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE = InnoDB COMMENT = 'Defines asset condition types';

CREATE TABLE
    Assets_TB (
        asset_id INT AUTO_INCREMENT PRIMARY KEY,
        asset_type_id INT COMMENT 'Reference to AssetTypes',
        make VARCHAR(100) COMMENT 'Asset make',
        model VARCHAR(100) COMMENT 'Asset model',
        asset_serial_number VARCHAR(100) UNIQUE COMMENT 'Asset serial number',
        procurement_date DATE COMMENT 'Date of procurement',
        asset_price DECIMAL(10, 2) COMMENT 'Asset price must be non-negative',
        vendor_id INT COMMENT 'Reference to Vendors',
        asset_warranty_start_date DATE COMMENT 'Warranty start date',
        asset_warranty_end_date DATE COMMENT 'Warranty end date',
        asset_status_id INT COMMENT 'Reference to AssetStatus',
        asset_condition_id INT COMMENT 'Reference to AssetConditions',
        asset_current_site_id INT COMMENT 'Reference to Sites',
        assigned_to_user_id INT COMMENT 'Reference to Users',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (asset_type_id) REFERENCES AssetTypes_TB (asset_type_id),
        FOREIGN KEY (vendor_id) REFERENCES Vendors_TB (vendor_id),
        FOREIGN KEY (asset_status_id) REFERENCES AssetStatus_TB (status_id),
        FOREIGN KEY (asset_condition_id) REFERENCES AssetConditions_TB (asset_condition_id),
        FOREIGN KEY (asset_current_site_id) REFERENCES Sites_TB (site_id),
        FOREIGN KEY (assigned_to_user_id) REFERENCES Users_TB (user_id)
    ) ENGINE = InnoDB COMMENT = 'Stores asset details';

CREATE TABLE
    AssetHistory_TB (
        history_id INT AUTO_INCREMENT PRIMARY KEY,
        asset_id INT COMMENT 'Reference to Assets',
        from_site_id INT COMMENT 'Previous site',
        to_site_id INT COMMENT 'New site',
        change_date DATETIME NOT NULL COMMENT 'Date of change',
        remarks TEXT COMMENT 'Remarks for the change',
        FOREIGN KEY (asset_id) REFERENCES Assets_TB (asset_id),
        FOREIGN KEY (from_site_id) REFERENCES Sites_TB (site_id),
        FOREIGN KEY (to_site_id) REFERENCES Sites_TB (site_id),
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE = InnoDB COMMENT = 'Tracks asset movements';

-- 4. Procurement Management
CREATE TABLE
    RequestApprovalStatus_TB (
        approval_status_id INT AUTO_INCREMENT PRIMARY KEY,
        approval_status_name VARCHAR(50) NOT NULL COMMENT 'Status of the request',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE = InnoDB COMMENT = 'Defines request approval status types';

CREATE TABLE
    ProcurementRequests_TB (
        request_id INT AUTO_INCREMENT PRIMARY KEY,
        requester_id INT COMMENT 'Reference to Users',
        asset_type_id INT COMMENT 'Reference to AssetTypes',
        request_date DATE NOT NULL COMMENT 'Request date',
        approval_status_id INT COMMENT 'Reference to RequestApprovalStatus',
        request_approved_by_user_id INT COMMENT 'Reference to Users',
        request_approval_date DATE COMMENT 'Approval date',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (requester_id) REFERENCES Users_TB (user_id),
        FOREIGN KEY (asset_type_id) REFERENCES AssetTypes_TB (asset_type_id),
        FOREIGN KEY (approval_status_id) REFERENCES RequestApprovalStatus_TB (approval_status_id),
        FOREIGN KEY (request_approved_by_user_id) REFERENCES Users_TB (user_id)
    ) ENGINE = InnoDB COMMENT = 'Manages procurement requests';

CREATE TABLE
    PurchaseOrders_TB (
        po_id INT AUTO_INCREMENT PRIMARY KEY,
        vendor_id INT COMMENT 'Reference to Vendors',
        request_id INT COMMENT 'Reference to ProcurementRequests',
        order_date DATE NOT NULL COMMENT 'Order date',
        delivery_date DATE COMMENT 'Delivery date',
        total_cost DECIMAL(10, 2) COMMENT 'Total order cost',
        terms TEXT COMMENT 'Terms of the order',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (vendor_id) REFERENCES Vendors_TB (vendor_id),
        FOREIGN KEY (request_id) REFERENCES ProcurementRequests_TB (request_id)
    ) ENGINE = InnoDB COMMENT = 'Manages purchase orders';

CREATE TABLE
    Vendors_TB (
        vendor_id INT AUTO_INCREMENT PRIMARY KEY,
        vendor_name VARCHAR(100) NOT NULL COMMENT 'Vendor name',
        contact_email VARCHAR(100) COMMENT 'Vendor contact email',
        contact_phone VARCHAR(20) COMMENT 'Vendor contact phone',
        rating DECIMAL(2, 1) COMMENT 'Vendor rating',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE = InnoDB COMMENT = 'Stores vendor details';

-- 5. Repairs and Maintenance
CREATE TABLE
    Repairs_TB (
        repair_id INT AUTO_INCREMENT PRIMARY KEY,
        asset_id INT COMMENT 'Reference to Assets',
        status_id INT COMMENT 'Reference to RepairStatus',
        repair_assigned_to_technician_id INT COMMENT 'Technician handling the repair',
        repair_start_datetime DATETIME COMMENT 'Start date and time of the repair',
        repair_completion_date DATE COMMENT 'Completion date of the repair',
        repair_cost DECIMAL(10, 2) COMMENT 'Cost of the repair',
        repair_parts_used TEXT COMMENT 'Parts used during repair',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (asset_id) REFERENCES Assets_TB (asset_id),
        FOREIGN KEY (status_id) REFERENCES RepairStatus_TB (status_id),
        FOREIGN KEY (repair_assigned_to_technician_id) REFERENCES Users_TB (user_id)
    ) ENGINE = InnoDB COMMENT = 'Tracks repair information';

CREATE TABLE
    RepairStatus_TB (
        status_id INT AUTO_INCREMENT PRIMARY KEY,
        repair_status VARCHAR(50) NOT NULL COMMENT 'Status of the repair',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE = InnoDB COMMENT = 'Defines repair status types';

CREATE TABLE
    MaintenanceSchedules_TB (
        schedule_id INT AUTO_INCREMENT PRIMARY KEY,
        asset_id INT COMMENT 'Reference to Assets',
        maintenance_scheduled_date DATE NOT NULL COMMENT 'Scheduled maintenance date',
        maintenance_completed_date DATE COMMENT 'Maintenance completion date',
        maintenance_assigned_to_technician_id INT COMMENT 'Technician handling the maintenance',
        notes TEXT COMMENT 'Maintenance notes',
        maintenance_cost DECIMAL(10, 2) COMMENT 'Maintenance cost',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (asset_id) REFERENCES Assets_TB (asset_id),
        FOREIGN KEY (maintenance_assigned_to_technician_id) REFERENCES Users_TB (user_id)
    ) ENGINE = InnoDB COMMENT = 'Schedules and tracks maintenance';

-- 6. Notifications
CREATE TABLE
    NotificationsTypes_TB (
        notification_type_id INT AUTO_INCREMENT PRIMARY KEY,
        notification_type_name VARCHAR(50) NOT NULL COMMENT 'Type of notification',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE = InnoDB COMMENT = 'Defines notification types';

CREATE TABLE
    Notifications_TB (
        notification_id INT AUTO_INCREMENT PRIMARY KEY,
        recipient_id INT COMMENT 'User receiving the notification',
        message TEXT NOT NULL COMMENT 'Notification message',
        notification_type_id INT COMMENT 'Reference to NotificationsType',
        TIMESTAMP DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Notification timestamp',
        notification_read_status BOOLEAN DEFAULT FALSE COMMENT 'Read status',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (recipient_id) REFERENCES Users_TB (user_id),
        FOREIGN KEY (notification_type_id) REFERENCES NotificationsTypes_TB (notification_type_id)
    ) ENGINE = InnoDB COMMENT = 'Manages notifications';

-- 7. Reports and Analytics
CREATE TABLE
    Reports_TB (
        report_id INT AUTO_INCREMENT PRIMARY KEY,
        report_type VARCHAR(50) NOT NULL COMMENT 'Type of report',
        report_generated_by_user_id INT COMMENT 'User who generated the report',
        generated_date DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Date generated',
        report_exported_format_enum ENUM ('PDF', 'Excel', 'CSV') COMMENT 'Export format',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (report_generated_by_user_id) REFERENCES Users_TB (user_id)
    ) ENGINE = InnoDB COMMENT = 'Tracks report generation and exports';