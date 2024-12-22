-- Revised MySQL Database Schema with Improvements
-- 2. User Management
CREATE TABLE
    Users (
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
        FOREIGN KEY (user_role_id) REFERENCES UserRoles (role_id),
        FOREIGN KEY (site_id) REFERENCES Sites (site_id)
    ) ENGINE = InnoDB COMMENT = 'Stores user information';

CREATE TABLE
    UserRoles (
        role_id INT AUTO_INCREMENT PRIMARY KEY,
        role_name VARCHAR(50) NOT NULL COMMENT 'Role name',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (added_by) REFERENCES Users (user_id),
        FOREIGN KEY (updated_by) REFERENCES Users (user_id)
    ) ENGINE = InnoDB COMMENT = 'Stores user roles';

CREATE TABLE
    AuthenticationLogs (
        log_id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL COMMENT 'Reference to Users',
        login_timestamp DATETIME NOT NULL COMMENT 'Login time',
        logout_timestamp DATETIME COMMENT 'Logout time',
        FOREIGN KEY (user_id) REFERENCES Users (user_id)
    ) ENGINE = InnoDB COMMENT = 'Tracks user authentication events';

-- 3. Sites
CREATE TABLE
    Sites (
        site_id INT AUTO_INCREMENT PRIMARY KEY,
        site_name VARCHAR(100) NOT NULL COMMENT 'Name of the site',
        site_location VARCHAR(255) COMMENT 'Location of the site',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (added_by) REFERENCES Users (user_id),
        FOREIGN KEY (updated_by) REFERENCES Users (user_id)
    ) ENGINE = InnoDB COMMENT = 'Stores site information';

-- 4. Asset Management
CREATE TABLE
    AssetTypes (
        asset_type_id INT AUTO_INCREMENT PRIMARY KEY,
        asset_type_name VARCHAR(50) NOT NULL COMMENT 'Type of asset',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (added_by) REFERENCES Users (user_id),
        FOREIGN KEY (updated_by) REFERENCES Users (user_id)
    ) ENGINE = InnoDB COMMENT = 'Defines types of assets';

CREATE TABLE
    AssetStatus (
        status_id INT AUTO_INCREMENT PRIMARY KEY,
        status_name VARCHAR(50) NOT NULL COMMENT 'Status of the asset',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (added_by) REFERENCES Users (user_id),
        FOREIGN KEY (updated_by) REFERENCES Users (user_id)
    ) ENGINE = InnoDB COMMENT = 'Defines asset status types';

CREATE TABLE
    AssetConditions (
        asset_condition_id INT AUTO_INCREMENT PRIMARY KEY,
        asset_condition_name VARCHAR(50) NOT NULL COMMENT 'Condition of the asset',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (added_by) REFERENCES Users (user_id),
        FOREIGN KEY (updated_by) REFERENCES Users (user_id)
    ) ENGINE = InnoDB COMMENT = 'Defines asset condition types';

CREATE TABLE
    Assets (
        asset_id INT AUTO_INCREMENT PRIMARY KEY,
        asset_type_id INT COMMENT 'Reference to AssetTypes',
        make VARCHAR(100) COMMENT 'Asset make',
        model VARCHAR(100) COMMENT 'Asset model',
        asset_serial_number VARCHAR(100) UNIQUE COMMENT 'Asset serial number',
        procurement_date DATE COMMENT 'Date of procurement',
        asset_price DECIMAL(10, 2) CHECK (asset_price >= 0) COMMENT 'Asset price must be non-negative',
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
        FOREIGN KEY (asset_type_id) REFERENCES AssetTypes (asset_type_id),
        FOREIGN KEY (vendor_id) REFERENCES Vendors (vendor_id),
        FOREIGN KEY (asset_status_id) REFERENCES AssetStatus (status_id),
        FOREIGN KEY (asset_condition_id) REFERENCES AssetConditions (asset_condition_id),
        FOREIGN KEY (asset_current_site_id) REFERENCES Sites (site_id),
        FOREIGN KEY (assigned_to_user_id) REFERENCES Users (user_id),
        CHECK (
            asset_warranty_end_date >= asset_warranty_start_date
            OR asset_warranty_end_date IS NULL
        ) COMMENT 'Warranty end date must be after start date',
        FOREIGN KEY (added_by) REFERENCES Users (user_id),
        FOREIGN KEY (updated_by) REFERENCES Users (user_id)
    ) ENGINE = InnoDB COMMENT = 'Stores asset details';

CREATE TABLE
    AssetHistory (
        history_id INT AUTO_INCREMENT PRIMARY KEY,
        asset_id INT COMMENT 'Reference to Assets',
        from_site_id INT COMMENT 'Previous site',
        to_site_id INT COMMENT 'New site',
        change_date DATETIME NOT NULL COMMENT 'Date of change',
        remarks TEXT COMMENT 'Remarks for the change',
        FOREIGN KEY (asset_id) REFERENCES Assets (asset_id),
        FOREIGN KEY (from_site_id) REFERENCES Sites (site_id),
        FOREIGN KEY (to_site_id) REFERENCES Sites (site_id),
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (added_by) REFERENCES Users (user_id),
        FOREIGN KEY (updated_by) REFERENCES Users (user_id)
    ) ENGINE = InnoDB COMMENT = 'Tracks asset movements';

-- 5. Procurement Management
CREATE TABLE
    RequestApprovalStatus (
        approval_status_id INT AUTO_INCREMENT PRIMARY KEY,
        approval_status_name VARCHAR(50) NOT NULL COMMENT 'Status of the request',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (added_by) REFERENCES Users (user_id),
        FOREIGN KEY (updated_by) REFERENCES Users (user_id)
    ) ENGINE = InnoDB COMMENT = 'Defines request approval status types';

CREATE TABLE
    ProcurementRequests (
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
        FOREIGN KEY (requester_id) REFERENCES Users (user_id),
        FOREIGN KEY (asset_type_id) REFERENCES AssetTypes (asset_type_id),
        FOREIGN KEY (approval_status_id) REFERENCES RequestApprovalStatus (approval_status_id),
        FOREIGN KEY (request_approved_by_user_id) REFERENCES Users (user_id),
        FOREIGN KEY (added_by) REFERENCES Users (user_id),
        FOREIGN KEY (updated_by) REFERENCES Users (user_id)
    ) ENGINE = InnoDB COMMENT = 'Manages procurement requests';

CREATE TABLE
    PurchaseOrders (
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
        FOREIGN KEY (vendor_id) REFERENCES Vendors (vendor_id),
        FOREIGN KEY (request_id) REFERENCES ProcurementRequests (request_id),
        FOREIGN KEY (added_by) REFERENCES Users (user_id),
        FOREIGN KEY (updated_by) REFERENCES Users (user_id)
    ) ENGINE = InnoDB COMMENT = 'Manages purchase orders';

CREATE TABLE
    Vendors (
        vendor_id INT AUTO_INCREMENT PRIMARY KEY,
        vendor_name VARCHAR(100) NOT NULL COMMENT 'Vendor name',
        contact_email VARCHAR(100) COMMENT 'Vendor contact email',
        contact_phone VARCHAR(20) COMMENT 'Vendor contact phone',
        rating DECIMAL(2, 1) COMMENT 'Vendor rating',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (added_by) REFERENCES Users (user_id),
        FOREIGN KEY (updated_by) REFERENCES Users (user_id)
    ) ENGINE = InnoDB COMMENT = 'Stores vendor details';

-- 6. Repairs and Maintenance
CREATE TABLE
    Repairs (
        repair_id INT AUTO_INCREMENT PRIMARY KEY,
        asset_id INT COMMENT 'Reference to Assets',
        status_id INT COMMENT 'Reference to RepairStatus',
        repair_assigned_to_technician_id INT COMMENT 'Technician handling the repair',
        repair_start_datetime DATETIME COMMENT 'Start date and time of the repair',
        repair_completion_date DATE COMMENT 'Completion date of the repair',
        repair_cost DECIMAL(10, 2) CHECK (repair_cost >= 0) COMMENT 'Cost of the repair',
        repair_parts_used TEXT COMMENT 'Parts used during repair',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (asset_id) REFERENCES Assets (asset_id),
        FOREIGN KEY (status_id) REFERENCES RepairStatus (status_id),
        FOREIGN KEY (added_by) REFERENCES Users (user_id),
        FOREIGN KEY (updated_by) REFERENCES Users (user_id),
        FOREIGN KEY (repair_assigned_to_technician_id) REFERENCES Users (user_id)
    ) ENGINE = InnoDB COMMENT = 'Tracks repair information';

CREATE TABLE
    RepairStatus (
        status_id INT AUTO_INCREMENT PRIMARY KEY,
        repair_status VARCHAR(50) NOT NULL COMMENT 'Status of the repair',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (added_by) REFERENCES Users (user_id),
        FOREIGN KEY (updated_by) REFERENCES Users (user_id)
    ) ENGINE = InnoDB COMMENT = 'Defines repair status types';

CREATE TABLE
    MaintenanceSchedules (
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
        FOREIGN KEY (added_by) REFERENCES Users (user_id),
        FOREIGN KEY (updated_by) REFERENCES Users (user_id),
        FOREIGN KEY (asset_id) REFERENCES Assets (asset_id),
        FOREIGN KEY (maintenance_assigned_to_technician_id) REFERENCES Users (user_id)
    ) ENGINE = InnoDB COMMENT = 'Schedules and tracks maintenance';

-- 7. Notifications
CREATE TABLE
    NotificationsTypes (
        notification_type_id INT AUTO_INCREMENT PRIMARY KEY,
        notification_type_name VARCHAR(50) NOT NULL COMMENT 'Type of notification',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (added_by) REFERENCES Users (user_id),
        FOREIGN KEY (updated_by) REFERENCES Users (user_id)
    ) ENGINE = InnoDB COMMENT = 'Defines notification types';

CREATE TABLE
    Notifications (
        notification_id INT AUTO_INCREMENT PRIMARY KEY,
        recipient_id INT COMMENT 'User receiving the notification',
        message TEXT NOT NULL COMMENT 'Notification message',
        notification_type_id INT COMMENT 'Reference to NotificationsType',
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Notification timestamp',
        notification_read_status BOOLEAN DEFAULT FALSE COMMENT 'Read status',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (recipient_id) REFERENCES Users (user_id),
        FOREIGN KEY (notification_type_id) REFERENCES NotificationsTypes (notification_type_id),
        FOREIGN KEY (added_by) REFERENCES Users (user_id),
        FOREIGN KEY (updated_by) REFERENCES Users (user_id)
    ) ENGINE = InnoDB COMMENT = 'Manages notifications';

-- 8. Reports and Analytics
CREATE TABLE
    Reports (
        report_id INT AUTO_INCREMENT PRIMARY KEY,
        report_type VARCHAR(50) NOT NULL COMMENT 'Type of report',
        report_generated_by_user_id INT COMMENT 'User who generated the report',
        generated_date DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Date generated',
        report_exported_format_enum ENUM ('PDF', 'Excel', 'CSV') COMMENT 'Export format',
        added_by INT,
        added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_by INT,
        updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (added_by) REFERENCES Users (user_id),
        FOREIGN KEY (updated_by) REFERENCES Users (user_id),
        FOREIGN KEY (report_generated_by_user_id) REFERENCES Users (user_id)
    ) ENGINE = InnoDB COMMENT = 'Tracks report generation and exports';