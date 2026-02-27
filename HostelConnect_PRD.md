🏠

**HOSTELCONNECT GH**

Hostel Marketplace Platform

─────────────────────────────────────

**PRODUCT REQUIREMENTS DOCUMENT (PRD)**

Product Requirements Document (PRD)

Version: 1.0

Backend: Java (Spring Boot)

Target Market: Ghana Student Housing

Date: 2025

**1. Executive Summary**

HostelConnect GH is a web-based marketplace platform designed to connect
students and patrons searching for hostel accommodation in Ghana with
verified landlords and rental agents. The platform addresses a critical
gap in the Ghanaian student housing market --- the lack of a trusted,
centralized, and searchable directory of hostels near universities.

The platform operates on a three-actor model:

- Customers (Students/Patrons) --- Browse, search, filter, and express
    interest in available hostel listings.

- Agents (Landlords/Representatives) --- Onboard with verified
    identity, upload hostel listings with full details and location
    data, and communicate with interested customers.

- Administrators --- Verify agent identities, manage platform
    integrity, and oversee all platform operations.

+-----------------------------------------------------------------------+
| **Core Value Proposition**                                            |
|                                                                       |
| Every agent on HostelConnect GH is manually verified by an            |
| administrator before they can post a single listing. This creates a   |
| trust layer that distinguishes this platform from social media groups |
| and informal channels that dominate hostel discovery in Ghana today.  |
+-----------------------------------------------------------------------+

**2. System Actors & Roles**

**2.1 Customer (Student / Patron)**

A customer is any person searching for hostel accommodation. They
require no verification to browse but must register to express interest
or contact an agent.

  --------------------- -------------------------------------------------
  **Capability**        **Description**

  **Browse Listings**   View all available and verified hostel listings

  **Search & Filter**   Filter by location, price, room type, amenities,
                        gender policy

  **Map View**          See hostel locations on an interactive map

  **Express Interest**  Formally indicate interest in a hostel listing

  **View Agent          Access agent contact info after expressing
  Contact**             interest

  **Manage Profile**    Update personal details and preferences

  **View History**      See all hostels they have shown interest in
  --------------------- -------------------------------------------------

**2.2 Agent (Landlord / Representative)**

An agent is a landlord or their authorized representative who lists
hostels for rent. Agents must pass an identity verification process
before they can create any listing.

  --------------------- -------------------------------------------------
  **Capability**        **Description**

  **Register & Upload   Submit Ghana Card or Student ID for verification
  ID**

  **Create Listings**   Post hostel details, photos, location, pricing
                        (VERIFIED only)

  **Manage Listings**   Edit, update availability, or deactivate their
                        listings

  **View Inquiries**    See all customers who expressed interest in their
                        listings

  **Communicate**       Contact interested customers via revealed contact
                        details

  **Manage Profile**    Update agency/personal info and contact details

  **Re-submit ID**      Upload a new ID document if previously rejected
  --------------------- -------------------------------------------------

**2.3 Administrator**

The administrator is a platform staff member responsible for agent
verification and platform governance.

  --------------------- -------------------------------------------------
  **Capability**        **Description**

  **View Verification   See all pending agent ID submissions with
  Queue**               timestamps

  **Review ID           Securely view uploaded identity documents
  Documents**

  **Approve / Reject    Approve verified agents or reject with reason
  Agents**

  **Suspend Agents**    Suspend an agent and auto-delist their listings

  **Manage All          Edit or remove any listing that violates platform
  Listings**            rules

  **Manage All Users**  View, deactivate, or delete any customer or agent
                        account

  **View Dashboard**    See platform analytics, verification stats,
                        listing counts
  --------------------- -------------------------------------------------

**2.4 Super Admin (Future Phase)**

A Super Admin manages other admin accounts and has full platform access.
This role is scoped for a future phase but should be architecturally
considered from Phase 1.

**3. Agent Verification Status Lifecycle**

Every agent account must move through a clearly defined status
lifecycle. This status gates what actions an agent is permitted to take
on the platform.

  ------------- --------------- ---------------------- -------------------
  **Status**    **Trigger**     **Agent Permissions**  **Admin Action
                                                       Required**

  UNVERIFIED    Agent registers Profile only. Cannot   None
                account         list.

  PENDING       Agent submits   Profile only. Cannot   Review submission
                ID document     list.

  VERIFIED      Admin approves  Full access. Can list  None
                submission      hostels.

  REJECTED      Admin rejects   Can re-upload ID       Reason provided
                submission      document.

  SUSPENDED     Admin suspends  Read-only. Listings    None
                account         auto-hidden.
  ------------- --------------- ---------------------- -------------------

+-----------------------------------------------------------------------+
| **Important Rule**                                                    |
|                                                                       |
| An agent\'s listings must automatically go offline (status = HIDDEN)  |
| the moment their account is SUSPENDED. When an agent is re-verified   |
| after suspension, listings remain HIDDEN until the agent manually     |
| re-activates them to prevent stale listings from appearing            |
| automatically.                                                        |
+-----------------------------------------------------------------------+

**4. Functional Requirements**

**4.1 Authentication & User Management**

**FR-AUTH-01: Customer Registration**

- Fields: Full Name, Email, Phone Number, Password, Confirm Password

- Email verification required before account activation

- Password minimum: 8 characters, 1 uppercase, 1 number

- Duplicate email detection with clear error message

**FR-AUTH-02: Agent Registration**

- Fields: Full Name, Email, Phone Number, Agency/Business Name
    (optional), Password

- On successful registration, agent status = UNVERIFIED

- System prompts agent to upload ID document immediately after
    registration

**FR-AUTH-03: Login (All Roles)**

- Email + Password authentication

- Role-based redirection after login (Customer Dashboard, Agent
    Dashboard, Admin Panel)

- On successful login, two tokens are issued:
  - **Access Token (JWT):** Short-lived (15 minutes). Contains role
      claim and agent verification_status claim. Used to authenticate
      all API requests.
  - **Refresh Token:** Long-lived (7 days). Stored in an httpOnly
      cookie (not accessible to JavaScript). Used to obtain a new
      access token without re-login. Endpoint: POST
      /api/auth/refresh-token.

- Refresh token is rotated on every use (old token invalidated,
    new token issued). Invalidated tokens are stored in Redis with
    TTL equal to their remaining lifetime.

- \"Forgot Password\" flow via email OTP reset

- Account lockout after 5 consecutive failed login attempts (15-minute
    cooldown)

**FR-AUTH-04: Social Login (Phase 3)**

- Google OAuth2 login for customers

- Role assignment on first social login

**4.2 Agent ID Verification Module**

**FR-VER-01: ID Document Upload**

- Agent can upload Ghana Card image OR Student ID image

- Accepted formats: JPG, PNG, PDF --- max file size 5MB per document

- Agent can upload front and back of the document

- Document is stored in secure cloud storage (AWS S3 / Cloudinary) ---
    never in the database

- After submission, agent status changes to PENDING

- Agent sees a status tracker: \"Your ID is under review. We will
    notify you within 24--48 hours.\"

**FR-VER-02: Admin Email Alert on Submission**

- When agent submits ID, system sends an email to the admin email
    address

- Email subject: \"\[HostelConnect GH\] New Agent Verification Request
    --- {AgentName}\"

- Email body: Agent name, email, phone, submission time, and a direct
    link to the admin review panel

- If no admin action is taken within 48 hours, a reminder email is
    sent

**FR-VER-03: Admin Review Interface**

- Admin sees a verification queue sorted by submission date (oldest
    first)

- Each row shows: Agent Name, Email, Submission Date, Document Type,
    Status badge

- Admin clicks to open a detailed review panel showing the uploaded
    document

- Document is displayed as a secure, time-limited signed URL --- not a
    permanent public link

- Admin has two action buttons: APPROVE and REJECT

- Rejecting requires admin to select a reason: Blurry Image \| Wrong
    Document Type \| Expired ID \| Name Mismatch \| Other

- If \"Other\" is selected, admin must type a custom reason

**FR-VER-04: Agent Notification on Decision**

- On APPROVAL: Agent receives email --- \"Congratulations! Your
    identity has been verified. You can now create hostel listings.\"

- On REJECTION: Agent receives email with the specific reason and a
    link to re-upload their document

- On SUSPENSION: Agent receives email explaining the suspension and a
    contact email for appeals

**FR-VER-05: Re-submission Flow**

- A REJECTED agent can upload a new document without creating a new
    account

- Re-submission resets their status to PENDING and triggers a new
    admin email alert

- Re-submission is limited to 3 attempts. After 3 rejections, account
    requires admin to manually unlock

- When an admin manually unlocks an account (resets it from the locked
    state), the `submission_count` is reset to 0, giving the agent a
    fresh set of 3 attempts. The admin must provide a reason for the
    unlock, which is stored in the audit log.

**4.3 Hostel Listing Module**

**FR-LIST-01: Create Listing (Verified Agents Only)**

Only agents with status = VERIFIED can access the Create Listing
feature. API enforces this at the backend regardless of frontend state.

Required listing fields:

- Hostel Name

- Description (rich text, min 100 characters)

- Hostel Type: Hostel \| Apartment \| Self-contained \| Shared Room

- Gender Policy: Male Only \| Female Only \| Mixed

- Address (human-readable street address)

- Region / City / Nearest University or Landmark

- GPS Coordinates (latitude, longitude --- via map picker or
    auto-detect)

- Room Types Available: Single \| Double \| Triple \| Shared Hall

- Price per Room (GHS) --- with billing period: Per Semester \| Per
    Year \| Per Month

- Number of Available Rooms

- Amenities checklist: Water \| Electricity \| WiFi \| Security \|
    Kitchen \| Laundry \| Generator \| Parking \| Study Room

- Contact Phone (defaults to agent profile phone, can override per
    listing)

- Contact WhatsApp Number (optional)

- Photos: minimum 3, maximum 15 images --- each max 5MB

**FR-LIST-02: Listing Status**

  --------------------- -------------------------------------------------
  **Status**            **Meaning**

  **ACTIVE**            Live and visible to customers

  **FULLY_BOOKED**      Visible but marked as no available rooms

  **COMING_SOON**       Visible but not yet available for occupancy

  **INACTIVE**          Hidden from customers (agent deactivated it)

  **UNDER_REVIEW**      Flagged by admin --- hidden pending review

  **HIDDEN**            Auto-hidden due to agent suspension
  --------------------- -------------------------------------------------

**FR-LIST-03: Edit & Manage Listings**

- Agent can edit any field of their listing at any time

- Agent can toggle availability (rooms remaining count)

- Agent can change listing status (ACTIVE / FULLY_BOOKED / COMING_SOON
    / INACTIVE)

- Agent can delete their own listing (soft delete --- data retained
    for 30 days)

- Agent can add or remove photos from an existing listing

**FR-LIST-04: Photo Upload Requirements**

- Minimum 3 photos required to publish a listing

- Supported formats: JPG, PNG, WEBP

- Max 5MB per image

- Images are resized and optimized on upload (max 1200px wide)

- Agent can set a \"cover photo\" --- first photo in upload order is
    default cover

**4.4 Customer Discovery Module**

**FR-DISC-01: Browse Listings**

- All ACTIVE and FULLY_BOOKED listings visible to any visitor (no
    login required to browse)

- Default sort: Newest first

- Listing card shows: Cover photo, Hostel Name, Location, Price, Room
    Type, Gender Policy, Available Rooms badge, Agent name

**FR-DISC-02: Search & Filter**

- Search bar: full-text search on Hostel Name, Description, Location,
    Nearest University

- Filter by: Region/City, Price Range (GHS slider), Room Type, Gender
    Policy, Amenities (multi-select), Hostel Type, Availability Status

- Sort by: Newest \| Price (Low to High) \| Price (High to Low) \|
    Nearest (requires location permission)

**FR-DISC-03: Map View**

- Interactive map (Google Maps or Mapbox) showing all ACTIVE hostel
    listings as pins

- Clicking a pin opens a mini-card with Hostel Name, Price, Room Type,
    and a \"View Details\" button

- Map clusters pins when zoomed out to avoid clutter

- Customer can drag and zoom the map to explore different areas

- The map endpoint (GET /api/listings/map) supports optional bounding
    box filtering via query parameters: `?swLat=&swLng=&neLat=&neLng=`
    to limit results to the visible map area. This prevents large
    payloads when the platform scales to thousands of listings.

**FR-DISC-04: Listing Detail Page**

- Full photo gallery with lightbox viewer

- All listing details displayed (description, amenities, room types,
    price, gender policy)

- Embedded map showing exact hostel location

- Agent profile card: Name, business name, verified badge, member
    since, number of listings

- \"Show Interest\" button --- requires customer login

- Share listing button (generates shareable URL)

**4.5 Interest & Contact Module**

**FR-INT-01: Express Interest**

- Logged-in customer clicks \"Show Interest\" on a listing detail page

- System records the interest with timestamp

- Agent is notified by email: \"\[HostelConnect GH\] New Inquiry ---
    {ListingName}\"

- Email to agent contains: Customer name, customer phone number,
    customer email, listing name, timestamp

- Customer sees a confirmation: \"Your interest has been recorded. The
    agent will contact you shortly.\"

**FR-INT-02: Contact Information Reveal**

- After a customer expresses interest, the listing detail page shows
    the agent\'s contact phone and WhatsApp number

- WhatsApp \"Chat Now\" button opens wa.me deeplink pre-filled with
    listing name

- A customer can only express interest in the same listing once
    (button changes to \"Interest Registered\")

**FR-INT-03: Agent Inquiry Dashboard**

- Agent sees a list of all customers who expressed interest in their
    listings

- Table columns: Customer Name, Phone, Email, Listing Name, Date of
    Interest

- Agent can mark an inquiry as \"Contacted\" or \"Closed\"

**4.6 Notification System**

**FR-NOTIF-01: Email Notifications**

  -------------- --------------- ---------------------- -------------------
  **Trigger      **Recipient**   **Channel**            **Priority**
  Event**

  Agent submits  Admin           Email                  High
  ID for
  verification

  Admin approves Agent           Email                  High
  agent

  Admin rejects  Agent           Email                  High
  agent

  Admin suspends Agent           Email                  High
  agent

  Customer       Customer        Email                  Medium
  registers

  Customer       Agent           Email                  High
  expresses
  interest

  New listing    Customer        Email (Optional)       Low
  posted near
  customer
  interest area

  48hr no action Admin           Email Reminder         Medium
  on
  verification
  -------------- --------------- ---------------------- -------------------

**4.7 Admin Dashboard**

**FR-ADMIN-01: Platform Overview**

- Total registered users (customers + agents)

- Total verified agents vs pending vs rejected vs suspended

- Total listings (by status breakdown)

- Total interest/inquiry count

- New signups in last 7 days / 30 days

**FR-ADMIN-02: User Management**

- View all customers with: Name, Email, Phone, Registration Date,
    Status

- View all agents with: Name, Email, Verification Status, Listing
    Count, Registration Date

- Admin can deactivate or delete any account

- Admin can manually change an agent\'s verification status

**FR-ADMIN-03: Listing Management**

- Admin can view all listings regardless of status

- Admin can change any listing\'s status (including UNDER_REVIEW)

- Admin can permanently delete a listing

- Admin can flag a listing for review

**5. Non-Functional Requirements**

  --------------------- -------------------------------------------------
  **Category**          **Requirement**

  **Security**          All API endpoints secured with JWT authentication

  **Security**          ID documents accessible only to admins via signed
                        URLs with 15-minute expiry

  **Security**          HTTPS enforced on all endpoints

  **Security**          Passwords hashed with BCrypt (min strength 10)

  **Security**          Rate limiting: 100 requests/minute per IP on
                        public endpoints

  **Security**          Input validation and SQL injection prevention on
                        all endpoints

  **Performance**       Listing search results return in under 2 seconds
                        for up to 10,000 listings

  **Performance**       Image upload processing completes within 10
                        seconds

  **Performance**       API response time under 500ms for non-search
                        endpoints (95th percentile)

  **Scalability**       Stateless backend supports horizontal scaling

  **Scalability**       Database connection pooling (HikariCP)

  **Reliability**       Email delivery via SendGrid with retry on failure

  **Reliability**       System target uptime: 99.5%

  **Compliance**        ID documents stored with access logging for audit
                        trail

  **Compliance**        Users can request account deletion (data removed
                        within 30 days)

  **Usability**         Platform responsive on mobile (primary device for
                        Ghanaian users)

  **Usability**         Page load under 3 seconds on 3G connection
  --------------------- -------------------------------------------------

**6. Technology Stack**

  ------------------ ---------------- ---------------------- -------------------
  **Layer**          **Technology**   **Version / Notes**    **Purpose**

  Backend Framework  Spring Boot      3.x (Java 17+)         Core API framework

  Database           PostgreSQL       15+                    Primary relational
                                                             DB with PostGIS for
                                                             geo

  ORM                Spring Data      Latest                 Database access
                     JPA + Hibernate                         layer

  Authentication     Spring           JJWT 0.12+             Stateless auth with
                     Security + JWT                          role claims

  File Storage       AWS S3 or        SDK v2                 Secure ID & image
                     Cloudinary                              storage

  Email              Spring Mail +    Latest                 Transactional email
                     SendGrid                                delivery

  Maps               Google Maps API  Maps JS + Geocoding    Interactive maps,
                                                             location search

  Search             PostgreSQL       Phase 1-3              Hostel search and
                     Full-Text Search                        filtering

  Cache              Redis            7+                     Session cache, rate
                                                             limiting, OTP

  API Docs           Springdoc        2.x                    Auto API
                     OpenAPI                                 documentation

  Migrations         Flyway           Latest                 DB schema version
                                                             control

  Frontend           React + Next.js  14+                    SSR, SEO-friendly,
                                                             mobile responsive

  UI Library         Tailwind CSS +   Latest                 Component library
                     shadcn/ui

  Containerization   Docker + Docker  Latest                 Dev and prod
                     Compose                                 deployment

  Cloud Deploy       Railway / Render Phase 1: Railway       Hosting
                     / AWS

  CI/CD              GitHub Actions   Latest                 Automated testing
                                                             and deployment

  Monitoring         Spring           Latest                 Health checks and
                     Actuator +                              error tracking
                     Sentry
  ------------------ ---------------- ---------------------- -------------------

**7. Core Database Schema (Simplified)**

**7.1 Users Table**

  -------------------- ----------------------------------------------------
  **Column**           **Type & Notes**

  **id**               UUID PRIMARY KEY

  **full_name**        VARCHAR(255) NOT NULL

  **email**            VARCHAR(255) UNIQUE NOT NULL

  **phone_number**     VARCHAR(20)

  **role**             ENUM: CUSTOMER, AGENT, ADMIN, SUPER_ADMIN

  **email_verified**   BOOLEAN DEFAULT false

  **is_active**        BOOLEAN DEFAULT true

  **created_at**       TIMESTAMP WITH TIME ZONE

  **updated_at**       TIMESTAMP WITH TIME ZONE
  -------------------- ----------------------------------------------------

> **Note on Password Storage:** The `password_hash` field is intentionally
> excluded from the `users` table. Passwords are stored in a separate
> `user_credentials` table (see Section 7.6) to improve security
> separation and allow future support for multiple credential types
> (e.g., OAuth2 alongside password auth).

**7.2 Agent Profiles Table**

  --------------------------- -------------------------------------------------
  **Column**                  **Type & Notes**

  **id**                      UUID PRIMARY KEY

  **user_id**                 UUID FK → users.id

  **agency_name**             VARCHAR(255) NULLABLE

  **verification_status**     ENUM: UNVERIFIED, PENDING, VERIFIED, REJECTED,
                              SUSPENDED

  **id_document_type**        ENUM: GHANA_CARD, STUDENT_ID NULLABLE

  **id_document_front_url**   VARCHAR(500) --- S3/Cloudinary key, not public
                              URL

  **id_document_back_url**    VARCHAR(500) NULLABLE

  **rejection_reason**        TEXT NULLABLE

  **submission_count**        INT DEFAULT 0

  **verified_at**             TIMESTAMP NULLABLE

  **verified_by_admin_id**    UUID FK → users.id NULLABLE
  --------------------------- -------------------------------------------------

**7.3 Listings Table**

  ------------------------ -------------------------------------------------
  **Column**               **Type & Notes**

  **id**                   UUID PRIMARY KEY

  **agent_id**             UUID FK → agent_profiles.id

  **title**                VARCHAR(255) NOT NULL

  **description**          TEXT NOT NULL

  **hostel_type**          ENUM: HOSTEL, APARTMENT, SELF_CONTAINED,
                           SHARED_ROOM

  **gender_policy**        ENUM: MALE_ONLY, FEMALE_ONLY, MIXED

  **address**              TEXT NOT NULL

  **city**                 VARCHAR(100)

  **region**               VARCHAR(100)

  **nearest_university**   VARCHAR(255)

  **latitude**             DECIMAL(10,8)

  **longitude**            DECIMAL(11,8)

  **price_ghs**            DECIMAL(10,2) NOT NULL

  **billing_period**       ENUM: PER_SEMESTER, PER_YEAR, PER_MONTH

  **total_rooms**          INT

  **available_rooms**      INT

  **room_types**           JSONB --- array of room type strings: ["SINGLE",
                           "DOUBLE", "TRIPLE", "SHARED_HALL"]

  **amenities**            JSONB --- array of amenity strings

  **contact_phone**        VARCHAR(20)

  **contact_whatsapp**     VARCHAR(20)

  **status**               ENUM: ACTIVE, FULLY_BOOKED, COMING_SOON,
                           INACTIVE, UNDER_REVIEW, HIDDEN

  **created_at**           TIMESTAMP WITH TIME ZONE

  **updated_at**           TIMESTAMP WITH TIME ZONE

  **deleted_at**           TIMESTAMP WITH TIME ZONE NULLABLE --- set on
                           soft delete; NULL means not deleted. Records
                           with a non-NULL value are excluded from all
                           queries. Permanently purged after 30 days.
  ------------------------ -------------------------------------------------

**7.4 Listing Photos Table**

  ------------------ ----------------------------------------------------
  **Column**         **Type & Notes**

  **id**             UUID PRIMARY KEY

  **listing_id**     UUID FK → listings.id

  **photo_url**      VARCHAR(500) --- cloud storage key

  **is_cover**       BOOLEAN DEFAULT false

  **sort_order**     INT

  **uploaded_at**    TIMESTAMP
  ------------------ ----------------------------------------------------

**7.5 Interests Table**

  --------------------- -------------------------------------------------
  **Column**            **Type & Notes**

  **id**                UUID PRIMARY KEY

  **customer_id**       UUID FK → users.id

  **listing_id**        UUID FK → listings.id

  **status**            ENUM: PENDING, CONTACTED, CLOSED
                        - PENDING: default state; customer has expressed
                          interest but agent has not yet acted
                        - CONTACTED: agent has reached out to the customer
                        - CLOSED: inquiry resolved (booked or no longer
                          relevant)

  **created_at**        TIMESTAMP

  **UNIQUE CONSTRAINT** (customer_id, listing_id) --- prevents duplicate
                        interest
  --------------------- -------------------------------------------------

**7.6 User Credentials Table**

Passwords are stored in a dedicated table separate from the `users` table
to improve security isolation and support future multi-credential
authentication (e.g., a user may have both a password and an OAuth2
provider linked to the same account).

  --------------------- -------------------------------------------------
  **Column**            **Type & Notes**

  **id**                UUID PRIMARY KEY

  **user_id**           UUID FK → users.id UNIQUE --- one credential
                        record per user

  **password_hash**     VARCHAR(255) NOT NULL --- BCrypt hashed, min
                        strength 10

  **created_at**        TIMESTAMP WITH TIME ZONE

  **updated_at**        TIMESTAMP WITH TIME ZONE
  --------------------- -------------------------------------------------

**8. API Endpoint Reference**

**8.1 Authentication Endpoints**

  ------------- ----------------------------- ---------------------- -------------------
  **Method**    **Endpoint**                  **Access**             **Description**

  POST          /api/auth/register/customer   Public                 Register a new
                                                                     customer account

  POST          /api/auth/register/agent      Public                 Register a new
                                                                     agent account

  POST          /api/auth/login               Public                 Login; returns
                                                                     short-lived access
                                                                     token (JWT) +
                                                                     sets httpOnly
                                                                     refresh token
                                                                     cookie

  POST          /api/auth/refresh-token       Public                 Exchange refresh
                                                                     token cookie for
                                                                     new access token;
                                                                     rotates refresh
                                                                     token

  POST          /api/auth/logout              Authenticated          Invalidates refresh
                                                                     token in Redis

  POST          /api/auth/forgot-password     Public                 Trigger password
                                                                     reset email

  POST          /api/auth/reset-password      Public                 Submit new password
                                                                     with OTP

  POST          /api/auth/verify-email        Public                 Verify email with
                                                                     OTP token

  GET           /api/auth/me                  Authenticated          Get current user
                                                                     profile
  ------------- ----------------------------- ---------------------- -------------------

**8.2 Agent Verification Endpoints**

  ------------- -------------------------------------------- ---------------------- -------------------
  **Method**    **Endpoint**                                 **Access**             **Description**

  POST          /api/agents/verification/submit              Agent                  Upload ID documents
                                                                                    for verification

  GET           /api/agents/verification/status              Agent                  Get own
                                                                                    verification status

  GET           /api/admin/verifications                     Admin                  Get all pending
                                                                                    verification
                                                                                    requests

  GET           /api/admin/verifications/{agentId}           Admin                  View specific agent
                                                                                    verification
                                                                                    details

  POST          /api/admin/verifications/{agentId}/approve   Admin                  Approve an agent

  POST          /api/admin/verifications/{agentId}/reject    Admin                  Reject with reason

  POST          /api/admin/agents/{agentId}/suspend          Admin                  Suspend an agent

  POST          /api/admin/agents/{agentId}/unlock           Admin                  Manually unlock an
                                                                                    agent after 3
                                                                                    rejections; resets
                                                                                    submission_count
                                                                                    to 0
  ------------- -------------------------------------------- ---------------------- -------------------

**8.3 Listing Endpoints**

  ------------- ------------------------------------- ---------------------- -------------------
  **Method**    **Endpoint**                          **Access**             **Description**

  GET           /api/listings                         Public                 Get all active
                                                                             listings
                                                                             (paginated,
                                                                             filterable)

  GET           /api/listings/{id}                    Public                 Get single listing
                                                                             detail

  GET           /api/listings/map                     Public                 Get listings with
                                                                             coordinates for map
                                                                             view. Supports
                                                                             optional bounding
                                                                             box: ?swLat=&
                                                                             swLng=&neLat=&
                                                                             neLng=

  POST          /api/listings                         Verified Agent         Create a new
                                                                             listing

  PUT           /api/listings/{id}                    Verified Agent (Owner) Update a listing

  PATCH         /api/listings/{id}/status             Verified Agent (Owner) Change listing
                                                                             status

  DELETE        /api/listings/{id}                    Verified Agent (Owner) Soft delete a
                                                      / Admin                listing

  POST          /api/listings/{id}/photos             Verified Agent (Owner) Upload photos to
                                                                             listing

  DELETE        /api/listings/{id}/photos/{photoId}   Verified Agent (Owner) Remove a photo

  GET           /api/agents/me/listings               Agent                  Get all listings by
                                                                             current agent
  ------------- ------------------------------------- ---------------------- -------------------

**8.4 Interest Endpoints**

  ------------- ------------------------------- ---------------------- --------------------
  **Method**    **Endpoint**                    **Access**             **Description**

  POST          /api/listings/{id}/interest     Customer               Express interest in
                                                                       a listing

  GET           /api/customers/me/interests     Customer               Get customer\'s
                                                                       interest history

  GET           /api/agents/me/inquiries        Agent                  Get all inquiries on
                                                                       agent\'s listings

  PATCH         /api/agents/me/inquiries/{id}   Agent                  Update inquiry
                                                                       status
                                                                       (Contacted/Closed)
  ------------- ------------------------------- ---------------------- --------------------

  -----------------------------------------------------------------------
  **PART II --- SCRUM DEVELOPMENT PHASES**

  -----------------------------------------------------------------------

**9. Phased Development Plan**

The project is broken into 7 testable phases (sprints). Each phase
delivers a fully functional vertical slice that can be tested end-to-end
before proceeding. No phase begins until the previous phase has passed
its acceptance criteria.

+-----------------------------------------------------------------------+
| **How to Use These Phases**                                           |
|                                                                       |
| After the AI agent implements each phase, use the Testing Checklist   |
| provided for that phase to verify every feature before signalling     |
| readiness to proceed. Each phase is self-contained and builds upon    |
| the previous one.                                                     |
+-----------------------------------------------------------------------+

**PHASE 1 --- Foundation & Authentication**

  --------------------- -------------------------------------------------
  **Sprint Goal**       **A working backend and frontend skeleton where
                        customers, agents, and admins can register and
                        log in with proper role-based access.**

  **Estimated           5--7 days
  Duration**

  **Deliverable**       Running application with auth working for all 3
                        roles
  --------------------- -------------------------------------------------

**Backend Tasks (Java / Spring Boot)**

1. Initialize Spring Boot 3.x project with Maven/Gradle

2. Set up PostgreSQL database and connect via application.properties /
    environment variables

3. Configure Flyway for DB migrations --- create initial V1 migration
    for users table

4. Implement User entity with fields: id (UUID), full_name, email,
    phone_number, role (ENUM), email_verified, is_active, created_at.
    Note: password_hash is NOT stored on the User entity.

4a. Implement UserCredentials entity with fields: id (UUID), user_id
    (FK, UNIQUE), password_hash (VARCHAR 255). This is a 1-to-1
    relationship with User. Created atomically with the User record
    during registration.

1. Implement AgentProfile entity with fields: id, user_id,
    verification_status (ENUM), submission_count

2. Implement customer registration endpoint: POST
    /api/auth/register/customer

3. Implement agent registration endpoint: POST /api/auth/register/agent
    --- creates user + agent_profile with status UNVERIFIED

4. Implement login endpoint: POST /api/auth/login --- validates
    credentials, returns JWT with role + verification_status claims

5. Configure Spring Security JWT filter --- protect endpoints by role

6. Implement GET /api/auth/me --- returns current user details based on
    JWT

7. Implement email verification: on registration, generate 6-digit OTP,
    store in Redis with 15-min TTL, send to user email

8. Implement POST /api/auth/verify-email --- validates OTP, sets
    email_verified = true

9. Implement POST /api/auth/forgot-password --- generates reset OTP,
    sends to email

10. Implement POST /api/auth/reset-password --- validates OTP, updates
    password hash

11. Account lockout: track failed login attempts in Redis, lock account
    for 15 min after 5 failures

12. Configure Spring Mail with SendGrid (or SMTP) for email delivery

13. Set up Springdoc OpenAPI at /api-docs and Swagger UI at
    /swagger-ui.html

14. Set up Docker Compose file with PostgreSQL, Redis, and Spring Boot
    app

15. Seed admin account: create a Flyway data migration (V1_1) that
    inserts a default admin user into the `users` table with role=ADMIN
    and a corresponding `user_credentials` record. Admin credentials
    must be configurable via environment variables
    (ADMIN_EMAIL, ADMIN_PASSWORD) --- never hardcoded. The migration
    should be idempotent (use INSERT ... ON CONFLICT DO NOTHING).

16. Add POST /api/auth/refresh-token endpoint: accepts the httpOnly
    refresh token cookie, validates it against Redis, issues a new
    access token and rotates the refresh token.

**Frontend Tasks (React / Next.js)**

1. Initialize Next.js 14 project with Tailwind CSS and shadcn/ui

2. Create global layout with responsive navigation bar (logo, Login,
    Register links)

3. Build Customer Registration page with form validation

4. Build Agent Registration page with form validation

5. Build Login page with email + password form and error handling

6. Implement JWT storage in memory/httpOnly cookie and auth context

7. Build role-based routing: after login, redirect to correct dashboard

8. Build Customer Dashboard shell (empty, just the layout)

9. Build Agent Dashboard shell (empty, just the layout)

10. Build Admin Panel shell (empty, just the layout)

11. Build Email Verification page (accepts OTP from URL or input)

12. Build Forgot Password and Reset Password pages

13. Implement protected routes --- redirect to login if not
    authenticated

**Phase 1 --- Testing Checklist**

+-----------------------------------------------------------------------+
| **TEST BEFORE PROCEEDING**                                            |
|                                                                       |
| Every item below must pass before Phase 2 begins. Test each in the    |
| browser AND via Swagger/Postman.                                      |
+-----------------------------------------------------------------------+

**Customer Registration & Login**

- Register a new customer with valid details --- success message
    received

- Verify email with OTP --- account activated

- Login with verified customer --- JWT received, redirected to
    Customer Dashboard

- Login with unverified email --- error message shown

- Register with duplicate email --- error message shown

- Register with weak password (\< 8 chars) --- validation error shown

- Forgot password flow --- receive OTP, reset password, login with new
    password

- 5 failed logins --- account locked, 6th attempt shows lockout
    message

**Agent Registration & Login**

- Register a new agent --- success, agent_profile created with status
    UNVERIFIED

- Login as agent --- JWT contains role=AGENT and
    verificationStatus=UNVERIFIED

- Agent dashboard shell loads after login

**Admin Login**

- Login with seeded admin account --- redirected to Admin Panel shell

- JWT contains role=ADMIN

**Role-Based Access**

- A customer JWT cannot access /api/admin/\* --- returns 403

- An agent JWT cannot access /api/admin/\* --- returns 403

- Unauthenticated request to /api/auth/me --- returns 401

- Navigating to /admin in browser without admin token --- redirected
    to login

**PHASE 2 --- Agent ID Verification System**

  --------------------- -------------------------------------------------
  **Sprint Goal**       **Agents can upload their ID documents, admin
                        receives an email alert, admin can approve or
                        reject agents through a dedicated interface, and
                        agents receive email notifications on
                        decisions.**

  **Estimated           5--7 days
  Duration**

  **Deliverable**       Full ID verification workflow operational
                        end-to-end

  **Dependencies**      Phase 1 complete and tested
  --------------------- -------------------------------------------------

**Backend Tasks**

1. Set up AWS S3 bucket (or Cloudinary account) for document storage

2. Configure bucket with private ACL --- no public access to ID
    documents

3. Create Flyway migration V2: update agent_profiles table with full
    columns (id_document_type, id_document_front_url,
    id_document_back_url, rejection_reason, verified_at,
    verified_by_admin_id)

4. Implement POST /api/agents/verification/submit: accepts multipart
    file upload (front + back), validates file type/size, uploads to
    S3/Cloudinary with private access, updates agent status to PENDING,
    sends admin email alert

5. Build admin email template: HTML email with agent details and direct
    link to admin review panel

6. Implement admin email reminder: schedule a job (Spring Scheduler) to
    check for PENDING submissions older than 48 hours and re-send
    reminder to admin

7. Implement GET /api/admin/verifications: returns paginated list of
    agents with status filter, sorted by submission date

8. Implement GET /api/admin/verifications/{agentId}: returns agent
    details + pre-signed S3 URL for document (valid for 15 minutes only)

9. Implement POST /api/admin/verifications/{agentId}/approve: sets
    status = VERIFIED, records verified_at and verified_by_admin_id,
    sends approval email to agent

10. Implement POST /api/admin/verifications/{agentId}/reject: requires
    rejection_reason in request body, sets status = REJECTED, increments
    submission_count, sends rejection email with reason to agent

11. Implement POST /api/admin/agents/{agentId}/suspend: sets status =
    SUSPENDED, auto-sets all agent\'s ACTIVE listings to HIDDEN, sends
    suspension email to agent

12. Re-submission logic: if agent re-submits, validate submission_count
    \< 3, replace old document URLs, reset status to PENDING, trigger
    new admin email alert

13. GET /api/agents/verification/status: agent checks their own
    verification status and rejection reason

**Frontend Tasks**

1. Build Agent Verification Upload page: file picker for Ghana Card /
    Student ID, front and back upload, preview of selected files, submit
    button

2. Show agent verification status on Agent Dashboard: status badge
    (UNVERIFIED / PENDING / VERIFIED / REJECTED / SUSPENDED)

3. If status = PENDING, show: \"Your documents are under review. We
    will notify you within 24--48 hours.\"

4. If status = REJECTED, show: rejection reason + \"Re-upload
    Document\" button

5. If status = SUSPENDED, show: suspension message + contact admin
    email

6. Build Admin Verification Queue page: table of pending agents with
    Name, Email, Phone, Submission Date, Document Type

7. Build Admin Agent Review panel: display agent info + render uploaded
    ID document (via pre-signed URL) + Approve / Reject buttons

8. Reject modal: dropdown for rejection reason + optional custom reason
    text field

9. After admin action, show success toast and refresh verification
    queue

**Phase 2 --- Testing Checklist**

**Agent ID Upload**

- Agent uploads Ghana Card (JPG) --- file accepted, status changes to
    PENDING

- Agent uploads PDF --- accepted (under 5MB)

- Agent uploads file over 5MB --- rejected with error message

- Agent tries uploading unsupported file type (e.g., .exe) ---
    rejected

- Agent dashboard shows \"PENDING\" status badge after upload

**Admin Email Alert**

- Admin inbox receives email within 30 seconds of agent submission

- Email contains agent name, email, phone, submission date, and link
    to review panel

**Admin Approval**

- Admin clicks agent in queue, sees pre-signed document URL (not a
    permanent public URL)

- Admin approves agent --- agent status changes to VERIFIED in
    database

- Agent receives approval email

- Agent dashboard now shows \"VERIFIED\" badge

**Admin Rejection**

- Admin rejects with reason \"Blurry Image\" --- agent status changes
    to REJECTED

- Agent receives rejection email with reason \"Blurry Image\"

- Agent can re-upload document without creating a new account

- Re-upload triggers new admin email alert

- Third rejection: agent cannot resubmit --- error message shown

**Agent Suspension**

- Admin suspends agent --- status changes to SUSPENDED

- Any ACTIVE listings by that agent are automatically set to HIDDEN
    (verify in database)

- Agent receives suspension email

- Suspended agent cannot log in to create new listings

**Security**

- A customer JWT cannot call POST
    /api/admin/verifications/{id}/approve --- returns 403

- The pre-signed document URL expires after 15 minutes --- test by
    waiting and reloading

**PHASE 3 --- Hostel Listing Creation & Management**

  --------------------- -------------------------------------------------
  **Sprint Goal**       **Verified agents can create, edit, manage, and
                        upload photos for hostel listings. All listing
                        data is stored correctly with location
                        coordinates.**

  **Estimated           7--10 days
  Duration**

  **Deliverable**       Agent can create a fully detailed hostel listing
                        with photos and location

  **Dependencies**      Phase 2 complete and tested
  --------------------- -------------------------------------------------

**Backend Tasks**

1. Flyway migration V3: create listings table and listing_photos table
    with all fields

2. Create Listing entity and ListingPhoto entity with proper JPA
    relationships

3. Implement POST /api/listings: validates agent status = VERIFIED
    (throw 403 if not), accepts all listing fields, saves to database

4. Implement POST /api/listings/{id}/photos: accepts up to 15 images
    (multipart), validates count, type, and size, uploads to
    S3/Cloudinary public folder, saves URLs to listing_photos table,
    first photo = cover

5. Implement GET /api/agents/me/listings: paginated list of the
    authenticated agent\'s listings

6. Implement PUT /api/listings/{id}: update any listing field ---
    validates agent owns the listing (403 otherwise)

7. Implement PATCH /api/listings/{id}/status: change listing status ---
    validates ownership

8. Implement DELETE /api/listings/{id}: soft delete --- sets deleted_at
    timestamp, excludes from all queries

9. Implement DELETE /api/listings/{id}/photos/{photoId}: removes photo
    from storage and DB

10. Amenities stored as JSONB array in PostgreSQL

11. Location: validate latitude/longitude range, store as DECIMAL(10,8)
    and DECIMAL(11,8)

12. Business rule enforcement: listing requires minimum 3 photos before
    status can be set to ACTIVE (return 422 if not met)

**Frontend Tasks**

1. Build Create Listing multi-step form (Step 1: Basic Info, Step 2:
    Location, Step 3: Amenities & Rooms, Step 4: Photos, Step 5: Preview
    & Publish)

2. Step 2: Embed Google Maps / Mapbox picker --- agent clicks map to
    set coordinates, address auto-fills from reverse geocode

3. Step 4: Drag-and-drop photo uploader with preview, ability to
    reorder and set cover photo

4. Build Agent Listings management page: table of own listings with
    status badge, edit/delete/toggle actions

5. Build Edit Listing page: pre-fills all current values, allows
    partial edits

6. Status toggle dropdown per listing: Active / Fully Booked / Coming
    Soon / Inactive

7. Preview listing before publishing (shows customer-facing view)

8. Show \"You must be a verified agent to create listings\" gate if
    agent is not VERIFIED

**Phase 3 --- Testing Checklist**

**Listing Creation**

- VERIFIED agent creates listing with all required fields --- listing
    saved to database

- UNVERIFIED agent tries to create listing --- 403 error returned from
    API

- Create listing with fewer than 3 photos --- cannot set status to
    ACTIVE (422 error)

- Create listing with 3+ photos --- can publish successfully

- Upload a 6MB image --- rejected with error message

- Upload 16 photos --- rejected (max 15)

- Location picker: click on map --- coordinates saved correctly in
    database

**Listing Management**

- Agent can view all their listings on the listings management page

- Agent edits listing title --- change persists after save

- Agent changes listing status to FULLY_BOOKED --- status updates in
    database

- Agent soft-deletes a listing --- listing disappears from agent
    dashboard and from public listings

- Agent removes a photo from a listing --- photo removed from cloud
    storage and database

**Security & Validation**

- Agent A cannot edit Agent B\'s listing --- 403 returned

- Admin can edit any listing --- 200 returned

- Missing required field (e.g., price) --- validation error returned,
    listing not created

**PHASE 4 --- Customer Discovery (Browse, Search & Map)**

  --------------------- -------------------------------------------------
  **Sprint Goal**       **Customers (and anonymous visitors) can browse
                        all active listings, search and filter by
                        multiple criteria, and view hostel locations on
                        an interactive map.**

  **Estimated           5--7 days
  Duration**

  **Deliverable**       Public-facing listing discovery experience fully
                        functional

  **Dependencies**      Phase 3 complete with at least 5 seed listings in
                        database
  --------------------- -------------------------------------------------

**Backend Tasks**

1. Implement GET /api/listings with query parameters: search
    (full-text), region, city, minPrice, maxPrice, roomType,
    genderPolicy, amenities (multi), hostelType, status, page, size,
    sort

2. Full-text search using PostgreSQL tsvector on title, description,
    address, nearest_university columns

3. Implement GET /api/listings/map: returns only id, title, latitude,
    longitude, price_ghs, status for all ACTIVE listings --- lightweight
    endpoint for map pins. Accepts optional bounding box query params
    (swLat, swLng, neLat, neLng) to filter results to the visible map
    area. When no bounding box is provided, returns all ACTIVE listings
    (acceptable for Phase 4; revisit if listing count exceeds 5,000)

4. Implement GET /api/listings/{id}: full listing detail including
    photos array, agent profile card (name, agency_name, verified badge,
    listing_count, member_since)

5. Add database indexes on: status, region, city, gender_policy,
    price_ghs, latitude, longitude for query performance

6. Pagination: default 12 listings per page, configurable via size
    param (max 50)

7. Seed database with 10--15 realistic sample listings for testing

**Frontend Tasks**

1. Build public Listings Browse page: responsive grid of listing cards
    (cover photo, name, location, price, gender policy, available rooms
    badge)

2. Build search bar with instant search-as-you-type (debounced 400ms)

3. Build filter panel: region dropdown, price range slider, room type
    checkboxes, gender policy radio, amenities multi-select, hostel type
    dropdown

4. Build sort controls: Newest \| Price Low-High \| Price High-Low

5. Implement pagination with page navigation

6. Build Listing Detail page: photo gallery with lightbox, all listing
    fields displayed, embedded map showing hostel location pin, agent
    profile card with verified badge

7. Build Map View page: Google Maps / Mapbox with all listing pins, pin
    click shows mini-card with basic details + View Listing button,
    cluster pins when zoomed out

8. Toggle between Grid View and Map View

9. Fully_BOOKED listings show \"Fully Booked\" badge overlay on card

10. Mobile responsive: single column on mobile, 2-col on tablet, 3-col
    on desktop

**Phase 4 --- Testing Checklist**

**Browse & Display**

- Anonymous visitor can browse listings without logging in

- All ACTIVE listings appear on browse page

- INACTIVE and HIDDEN listings do NOT appear

- Listing card shows correct cover photo, name, location, price,
    gender policy

- Clicking listing card opens detail page with all information

**Search & Filter**

- Search \"Legon\" --- returns listings near University of Ghana

- Filter by \"Female Only\" gender policy --- only female hostels
    shown

- Price slider: set range GHS 500--1000 --- only listings in that
    range shown

- Filter by \"WiFi\" amenity --- only listings with WiFi shown

- Combine search + filter --- results correctly intersected

- Sort by \"Price Low to High\" --- listings ordered correctly

**Map View**

- Map loads with hostel pins correctly positioned

- Clicking a pin shows mini-card with correct listing info

- \"View Listing\" in mini-card navigates to detail page

- Pins cluster when zoomed out

- Embedded map on detail page shows correct hostel location

**Performance**

- Browse page loads within 2 seconds with 10+ listings

- Search results update within 1 second after typing stops

**PHASE 5 --- Interest, Contact & Inquiry System**

  --------------------- -------------------------------------------------
  **Sprint Goal**       **Customers can express interest in listings,
                        agent contact details are revealed, agent
                        receives email alert, and agents can manage their
                        inquiries.**

  **Estimated           3--5 days
  Duration**

  **Deliverable**       Full interest-to-contact pipeline working

  **Dependencies**      Phase 4 complete and tested
  --------------------- -------------------------------------------------

**Backend Tasks**

1. Flyway migration V5: create interests table with UNIQUE constraint
    on (customer_id, listing_id)

2. Implement POST /api/listings/{id}/interest (Customer only): create
    interest record, trigger email to agent, return agent contact
    details in response

3. Agent interest email: HTML template with customer name, phone,
    email, listing title, interest timestamp, link to agent inquiry
    dashboard

4. Implement GET /api/customers/me/interests: list of all listings
    customer has shown interest in, with interest status and listing
    summary

5. Implement GET /api/agents/me/inquiries: paginated list of all
    inquiries on agent\'s listings --- columns: customer name, phone,
    email, listing name, date, status

6. Implement PATCH /api/agents/me/inquiries/{id}: update inquiry status
    (CONTACTED / CLOSED)

7. Business rule: if customer has already expressed interest in a
    listing, return 409 Conflict with message \"You have already shown
    interest in this listing\"

8. If a listing is INACTIVE or FULLY_BOOKED, customer can still express
    interest (agent may have a waitlist)

**Frontend Tasks**

1. On Listing Detail page: \"Show Interest\" button visible to all ---
    if not logged in, clicking redirects to login with return URL

2. After customer expresses interest: button changes to \"Interest
     Registered ✓\", agent contact panel appears with phone number and
     WhatsApp button

3. WhatsApp button: opens wa.me link pre-filled with message \"Hi,
     I\'m interested in \[Listing Name\] from HostelConnect GH\"

4. Build Customer Interest History page: list of all listings they\'ve
     shown interest in with status and agent contact

5. Build Agent Inquiry Dashboard: table with customer details and
     listing, status dropdown (CONTACTED / CLOSED), filter by listing

**Phase 5 --- Testing Checklist**

- Unauthenticated visitor clicks \"Show Interest\" --- redirected to
    login, returns to listing after login

- Logged-in customer clicks \"Show Interest\" --- interest recorded,
    contact details revealed, WhatsApp button appears

- WhatsApp button opens correct pre-filled chat link

- Agent receives email alert within 60 seconds of customer interest

- Customer clicks \"Show Interest\" again on same listing --- error:
    \"Already showed interest\"

- Customer sees all their interests on Interest History page

- Agent sees inquiry on Agent Inquiry Dashboard with correct customer
    details

- Agent marks inquiry as CONTACTED --- status updates in dashboard

- Agent JWT cannot call customer interest endpoints --- 403

**PHASE 6 --- Admin Dashboard & Platform Management**

  --------------------- -------------------------------------------------
  **Sprint Goal**       **Admin has a complete dashboard to see platform
                        statistics, manage all users, manage all
                        listings, and perform all governance actions from
                        a single interface.**

  **Estimated           5--7 days
  Duration**

  **Deliverable**       Full admin control panel operational

  **Dependencies**      Phase 5 complete and tested
  --------------------- -------------------------------------------------

**Backend Tasks**

1. Implement GET /api/admin/stats: returns total customers, total
     agents (by status), total listings (by status), total interests,
     new users this week/month

2. Implement GET /api/admin/users/customers: paginated, filterable
     customer list (search by name/email, filter by active status)

3. Implement GET /api/admin/users/agents: paginated agent list with
     verification status filter

4. Implement PATCH /api/admin/users/{id}/deactivate: deactivates any
     user account

5. Implement DELETE /api/admin/users/{id}: permanently deletes user
     (with cascade handling)

6. Implement GET /api/admin/listings: all listings regardless of
     status, with agent name

7. Implement PATCH /api/admin/listings/{id}/status: admin changes any
     listing status

8. Implement PATCH /api/admin/listings/{id}/flag: flags listing as
     UNDER_REVIEW

9. Implement DELETE /api/admin/listings/{id}: hard delete listing and
     all photos from storage

10. All admin endpoints must verify role=ADMIN in JWT, return 403
     otherwise

11. Implement audit logging: log all admin actions (action type, admin
     ID, target entity, timestamp) to a separate admin_audit_log table

**Frontend Tasks**

1. Build Admin Dashboard overview page: stat cards (Total Users,
     Verified Agents, Pending Verifications, Active Listings, Total
     Inquiries this week)

2. Build Admin Customer Management table: searchable, with
     deactivate/delete actions and confirmation modals

3. Build Admin Agent Management table: with verification status badge,
     listing count, approve/reject/suspend actions

4. Build Admin Listings Management table: search by title or agent
     name, status filter, with flag/status-change/delete actions

5. Admin sidebar navigation: Dashboard \| Verifications \| Customers
     \| Agents \| Listings \| Settings

6. All destructive actions (delete, suspend) require a confirmation
     modal with text confirmation (\"Type DELETE to confirm\")

**Phase 6 --- Testing Checklist**

- Admin dashboard shows accurate stat counts (verify against database)

- Admin can search for a specific customer by email --- found
    correctly

- Admin deactivates a customer --- customer cannot login (401
    returned)

- Admin views agent list filtered by PENDING status --- only pending
    agents shown

- Admin changes a listing status to UNDER_REVIEW --- listing
    disappears from public browse

- Admin deletes a listing --- listing and all photos removed from
    storage and database

- Non-admin JWT accessing admin endpoints --- 403 returned for all

- Admin audit log records: admin ID, action type, target entity,
    timestamp for every admin action

**PHASE 7 --- Polish, Security Hardening & Deployment**

  --------------------- -------------------------------------------------
  **Sprint Goal**       **Production-ready deployment with security
                        hardening, error handling, performance
                        optimizations, and CI/CD pipeline.**

  **Estimated           5--7 days
  Duration**

  **Deliverable**       Live deployed application on public URL, ready
                        for real users

  **Dependencies**      Phases 1--6 all complete and tested
  --------------------- -------------------------------------------------

**Backend Tasks**

1. Implement global exception handler (Spring \@ControllerAdvice):
     return consistent JSON error responses for validation errors, 401,
     403, 404, 500

2. Add input validation annotations (@Valid, \@NotNull, \@Size,
     \@Email) on all request DTOs

3. Implement rate limiting with Bucket4j: 100 req/min on public
     endpoints, 20 req/min on auth endpoints

4. Add CORS configuration: whitelist frontend origin

5. Security headers: add Content-Security-Policy, X-Frame-Options,
     X-Content-Type-Options via Spring Security

6. Enable HTTPS: configure SSL termination (handled by cloud provider
     or Nginx reverse proxy)

7. Add connection pooling configuration (HikariCP) with appropriate
     pool size

8. Add database query performance logging: log any query over 200ms

9. Spring Boot Actuator: enable /actuator/health and /actuator/info
     endpoints (secured)

10. Write unit tests for: agent status transitions, listing creation
     business rules, interest uniqueness constraint, admin authorization

11. Write integration tests for: full agent registration → verification
     → listing → interest flow

12. Set up Sentry (or similar) for error tracking and alerting

**Frontend Tasks**

1. Implement proper loading states and skeleton screens on all
     data-fetching pages

2. Implement error boundary components --- user-friendly error pages
     for 404 and 500

3. SEO: add Open Graph meta tags to listing detail pages (for
     WhatsApp/social sharing previews)

4. Progressive Web App (PWA) setup: service worker, web manifest for
     add-to-homescreen on mobile

5. Image lazy loading on listing browse page

6. Implement toast notification system for user feedback on all
     actions

7. Accessibility audit: all forms must have labels, buttons must have
     aria-labels, images must have alt text

**Deployment Tasks**

1. Set up GitHub Actions CI/CD pipeline: on push to main → run tests →
     build Docker image → deploy to cloud

2. Set up staging environment (deploy to staging on PR, production on
     merge to main)

3. Configure environment variables for all secrets (DB credentials,
     JWT secret, S3 keys, SendGrid key, Maps API key) --- never hardcode

4. Set up database backups (daily automated backup)

5. Configure custom domain and SSL certificate

6. Configure Cloudflare (or similar) as CDN for static assets and DDoS
     protection

**Phase 7 --- Testing Checklist**

**Security**

- Send request with missing JWT --- 401 returned with consistent JSON
    format

- Send request with malformed JWT --- 401 returned

- Send more than 100 requests in 1 minute from same IP --- 429 Too
    Many Requests returned

- SQL injection attempt in search query --- sanitized, no error, safe
    response returned

- XSS attempt in listing description --- stripped/escaped on render

**Production Readiness**

- Application starts successfully from Docker container with
    environment variables

- Health check endpoint /actuator/health returns 200 with status UP

- Full user journey works on production URL: Register → Verify Email →
    Agent Submits ID → Admin Approves → Agent Creates Listing → Customer
    Browses → Customer Shows Interest → Agent Receives Email

- Application loads correctly on mobile Chrome and Safari

- All listing images load from CDN correctly

- Listing detail page has correct Open Graph preview when URL is
    pasted in WhatsApp

**Performance**

- Browse page: 12 listings load in under 2 seconds on production

- Map view: loads all listing pins in under 3 seconds with 50+
    listings

- API response time under 500ms for 95% of requests (check logs)

**10. Future Phases (Post-MVP Roadmap)**

These features are explicitly out of scope for the initial 7 phases but
should be architecturally considered in the database design and API
structure.

  --------------- ------------------- ---------------------- -------------------
  **Feature**     **Description**     **Priority**           **Phase Target**

  In-App          Real-time chat      High                   Phase 8
  Messaging       between customer
                  and agent
                  (WebSocket / STOMP)

  Review & Rating Customers rate      High                   Phase 8
  System          agents and hostels
                  after inquiry

  Push            Firebase FCM for    Medium                 Phase 9
  Notifications   mobile push alerts
                  on
                  interest/approval

  Google OAuth    Social sign-in for  Medium                 Phase 9
  Login           customers

  Hostel          Customers subscribe Medium                 Phase 9
  Availability    to alerts when
  Alerts          hostels near a
                  university become
                  available

  Featured        Agents pay to have  High                   Phase 10
  Listings        listings appear at
                  the top of search
                  results

  Online Payment  Booking deposits    High                   Phase 10
  (Paystack)      processed through
                  Paystack Ghana

  Elasticsearch   Replace PostgreSQL  Medium                 Phase 11
                  FTS with
                  Elasticsearch for
                  advanced search at
                  scale

  Super Admin     Manage admin        Low                    Phase 12
  Role            accounts,
                  platform-wide
                  settings, audit
                  logs

  Analytics       Per-agent listing   Low                    Phase 12
  Dashboard       performance stats
                  (views, interests,
                  conversions)
  --------------- ------------------- ---------------------- -------------------

**11. Glossary**

  --------------------- -------------------------------------------------
  **Term**              **Definition**

  **Customer**          A student or patron looking for hostel
                        accommodation

  **Agent**             A landlord or rental representative who lists
                        hostels

  **Admin**             Platform staff member who verifies agents and
                        governs the platform

  **Listing**           A hostel property entry created by a verified
                        agent

  **Interest**          A customer\'s formal expression of interest in a
                        specific listing

  **Inquiry**           The same as Interest, viewed from the agent\'s
                        perspective

  **Ghana Card**        Ghana\'s national identity document issued by the
                        NIA

  **JWT**               JSON Web Token --- a signed authentication token
                        containing user role and claims

  **PENDING**           Agent has submitted ID documents, awaiting admin
                        review

  **VERIFIED**          Agent has been approved by admin and can list
                        hostels

  **REJECTED**          Agent\'s ID submission was rejected, can
                        re-submit

  **SUSPENDED**         Agent account deactivated by admin, listings
                        auto-hidden

  **Signed URL**        A time-limited, temporary URL for accessing
                        private cloud storage files

  **Soft Delete**       Mark a record as deleted without removing it from
                        the database permanently

  **PostGIS**           A PostgreSQL extension for geographic object
                        support and spatial queries

  **OTP**               One-Time Password --- a short-lived code used for
                        email verification and password reset

  **CORS**              Cross-Origin Resource Sharing --- browser
                        security policy for cross-domain requests

  **Flyway**            A Java database migration tool that tracks and
                        applies schema changes in order

  **HikariCP**          A high-performance JDBC connection pool used with
                        Spring Boot
  --------------------- -------------------------------------------------

*HostelConnect GH --- Product Requirements Document v1.0*

*This document is the single source of truth for all development phases.
Update it as requirements evolve.*
