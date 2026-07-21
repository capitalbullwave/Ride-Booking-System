# Corporate Ride Module — Phase 1 Testing Checklist

## Database
- [ ] Run `alembic upgrade head` (revision `031_corporate_module`)
- [ ] Confirm tables: `companies`, `company_employees`, `company_policies`
- [ ] Confirm `rides` columns: `ride_type`, `company_id`, `employee_id`, `payment_source`

## Company registration / login
- [ ] `POST /api/v1/corporate/register` creates company with status `PENDING`
- [ ] Duplicate email rejected
- [ ] `POST /api/v1/corporate/login` works for pending (read-only) and approved companies
- [ ] Suspended company cannot login productively / gets forbidden where expected

## Admin Panel
- [ ] Sidebar shows Corporate group (Dashboard, Companies, Employees, Rides, Policies, Reports)
- [ ] Dashboard cards and pending approvals load
- [ ] Approve / Reject / Suspend / Delete company
- [ ] Company detail shows GST, PAN, credit, spend, employees, rides
- [ ] Add employee by user phone; Activate / Deactivate / Remove
- [ ] Save ride policy (max amount, flags)
- [ ] Corporate rides list filters by company/status
- [ ] Reports show ride count / completed / cancelled / spend

## User app
- [ ] Profile shows Corporate Membership when linked
- [ ] Book screen shows Corporate Ride toggle when `can_book_corporate`
- [ ] Corporate mode: payment shows "Paid by Company" (no Cash/UPI/Wallet)
- [ ] Book sends `ride_type=CORPORATE`, `company_id`, `employee_id`
- [ ] Personal mode still books as `NORMAL` / user payment unchanged
- [ ] History shows Corporate badge + company name + Paid by Company

## Driver app (rider / gadi wale)
- [ ] Incoming corporate ride shows Corporate badge and company in passenger line
- [ ] Collect payment for COMPANY rides auto-completes (paid by company)

## Security
- [ ] Employee can only book for own company membership
- [ ] Company JWT cannot access another company’s admin APIs
- [ ] Platform admin can access all corporate admin endpoints

## Regression
- [ ] Existing personal ride booking / matching / tracking still works
- [ ] Non-corporate payment collection (cash / QR) unchanged
