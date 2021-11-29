{
    title: "VersaPay ARC",

    #HTTP basic auth
    connection: {
        fields: [{
            "name": "token",
            optional: false
        }, {
            "name": "key",
            "control_type": 'password',
            optional: false
        }, {
            "name": 'environment',
            type: 'boolean',
            optional: false,
            "control_type": "select",
            pick_list: [
                ["UAT", "https://uat.versapay.com"],
                ["Production", "https://secure.versapay.com"]
            ]
        }],

        authorization: {
            type: 'basic_auth',

            #Basic auth credentials are just the username(token) and password(key);framework handles adding# them to the HTTP requests.
            credentials: -> (connection) {
                user(connection['token'])
                password(connection['key'])
            }
        }
    },

    object_definitions: {
        generic_created_response: {
            fields: -> () {
                [{
                    "name": "identifier"
                }, {
                    "name": "message"
                }]
            }
        },
        customer_view: {
            fields: -> () {
                [{
                    "name": "identifier",
                    "optional": false,
                    "hint": "identifier of the customer record in ARC"
                }, {
                    "name": "name"
                }, {
                    "name": "email",
                    "control_type": "email"
                }, {
                    "name": "first_name",
                    "label": "First Name"
                }, {
                    "name": "last_name",
                    "label": "Last Name"
                }, {
                    "name": "notes",
                    "control_type": "text-area"
                }, {
                    "name": "address_1"
                }, {
                    "name": "address_2"
                }, {
                    "name": "city"
                }, {
                    "name": "province"
                }, {
                    "name": "postal_code",
                    "label": "Postal Code"
                }, {
                    "name": "country"
                }, {
                    "name": "telephone",
                    "control_type": "phone"
                }, {
                    "name": "fax",
                    "control_type": "phone"
                }, {
                    "name": "business_number",
                    "label": "Business Number"
                }, {
                    "name": "status",
                    "control_type": "select",
                    "pick_list": [
                        ["Not Activated", "Not Activated"],
                        ["Activated", "Activated"],
                        ["Invited", "Invited"],
                        ["Express", "Express"],
                        ["Signed Up", "Signed Up"],
                        ["Paying", "Paying"]
                    ]
                }, {
                    "name": "auto_debit",
                    "label": "Auto Debit",
                    "control_type": "select",
                    "type": "string",
                    "pick_list": [
                        ["Yes", "Y"],
                        ["No", "N"]
                    ]
                }, {
                    "name": "invite_sent",
                    "label": "Invite Sent",
                    "control_type": "date",
                    "type": "date",
                    "hint": "YYY-MM-DD format"
                }, {
                    "name": "signed_up",
                    "label": "Signed Up",
                    "control_type": "date",
                    "type": "date",
                    "hint": "YYY-MM-DD format"
                }, {
                    "name": "notification_suppressed",
                    "label": "Notification Suppressed",
                    "control_type": "select",
                    "type": "string",
                    "pick_list": [
                        ["Yes", "Y"],
                        ["No", "N"]
                    ]
                }, {
                    "name": "notification_override",
                    "label": "Notification Override",
                    "control_type": "select",
                    "type": "string",
                    "pick_list": [
                        ["Yes", "Y"],
                        ["No", "N"]
                    ]
                }, {
                    "name": "paper_invoices",
                    "label": "Paper Invoices",
                    "control_type": "select",
                    "type": "string",
                    "pick_list": [
                        ["Yes", "Y"],
                        ["No", "N"]
                    ]
                }, {
                    "name": "balance",
                    "control_type": "string",
                    "type": "string",
                    "hint": "Note: This field is prefixed with the currency code, for each currency the customer is transacting in (say, usd_balance). This applies to suppliers accepting multicurrency payments."
                }, {
                    "name": "credit",
                    "control_type": "string",
                    "type": "string",
                    "hint": "Note: This field is prefixed with the currency code, for each currency the customer is transacting in (say, usd_credit). This applies to suppliers accepting multicurrency payments."
                }, {
                    "name": "current",
                    "control_type": "string",
                    "type": "string",
                    "hint": "Note: This field is prefixed with the currency code, for each currency the customer is transacting in (say, usd_current). This applies to suppliers accepting multicurrency payments."
                }, {
                    "name": "aging",
                    "control_type": "string",
                    "type": "string",
                    "hint": "Note: This field is prefixed with the currency code, for each currency the customer is transacting in (say, usd_aging). This applies to suppliers accepting multicurrency payments."

                }, {
                    "name": "aging_30",
                    "control_type": "string",
                    "type": "string",
                    "hint": "Note: This field is prefixed with the currency code, for each currency the customer is transacting in (say, usd_aging_30). This applies to suppliers accepting multicurrency payments."

                }, {
                    "name": "aging_60",
                    "control_type": "string",
                    "type": "string",
                    "hint": "Note: This field is prefixed with the currency code, for each currency the customer is transacting in (say, usd_aging_60). This applies to suppliers accepting multicurrency payments."

                }, {
                    "name": "aging_90",
                    "control_type": "string",
                    "type": "string",
                    "hint": "Note: This field is prefixed with the currency code, for each currency the customer is transacting in (say, usd_aging_90). This applies to suppliers accepting multicurrency payments."

                }, {
                    "name": "aging_older",
                    "label": "Aging Older",
                    "control_type": "string",
                    "type": "string",
                    "hint": "Note: This field is prefixed with the currency code, for each currency the customer is transacting in (say, usd_aging_older). This applies to suppliers accepting multicurrency payments."

                }, {
                    "name": "unapplied_payment",
                    "label": "Unapplied Payment",
                    "control_type": "string",
                    "type": "string",
                    "hint": "Note: This field is prefixed with the currency code, for each currency the customer is transacting in (say, usd_unapplied_payment). This applies to suppliers accepting multicurrency payments."

                }, {
                    "name": "adp",
                    "label": "ADP (Average Days to Pay)",
                    "hint": "Average days to pay."
                }, {
                    "name": "adp_arc",
                    "label": "ADP in ARC"
                }, {
                    "name": "adp_external",
                    "label": "ADP External"
                }, {
                    "name": "last_contact_date",
                    "label": "Last Contact Date",
                    "control_type": "date",
                    "type": "date"
                }, {
                    "name": "next_contact_date",
                    "label": "Next Contact Date",
                    "control_type": "date",
                    "type": "date"
                }, {
                    "name": "credit_limit",
                    "label": "Credit Limit"
                }, {
                    "name": "oldest_open_invoice",
                    "label": "Oldest Open Invoice"
                }, {
                    "name": "oldest_open_invoice_age",
                    "label": "Oldest Open Invoice Age (in days)",
                    "hint": "Age (in days) of the oldest outstanding invoice."
                }, {
                    "name": "oldest_open_invoice_balance",
                    "label": "Oldest Open Invoice Balance"
                }, {
                    "name": "last_payment_date",
                    "label": "Last Payment Date",
                    "control_type": "date",
                    "type": "date"
                }, {
                    "name": "last_payment_amount",
                    "label": "Last Payment Amount"
                }, {
                    "name": "last_payment_source",
                    "label": "Last Payment Source",
                    "control_type": "select",
                    "type": "string",
                    "pick_list": [
                        ["arc", "arc"],
                        ["external", "external"],
                        ["erp", "erp"],
                        ["manual", "manual"]
                    ]
                }, {
                    "name": "account_status",
                    "label": "Account Status",
                    "control_type": "select",
                    "pick_list": [
                        ["Open", "open"],
                        ["Closed", "closed"],
                        ["On-Hold", "on_hold"]
                    ]
                }, {
                    "name": "tags"
                }, {
                    "name": "divisions_names",
                    "label": "Division Names"
                }, {
                    "name": "divisions_codes",
                    "label": "Division Codes"
                }]
            }
        },
        customer_edit: {
            fields: -> () {
                [{
                    "control_type": "text",
                    "label": "Identifier",
                    "type": "string",
                    "name": "identifier",
                    "optional": false
                }, {
                    "control_type": "text",
                    "label": "Name",
                    "type": "string",
                    "name": "name",
                    "optional": false
                }, {
                    "control_type": "email",
                    "label": "Email",
                    "type": "string",
                    "name": "email"
                }, {
                    "control_type": "text",
                    "label": "First Name",
                    "type": "string",
                    "name": "first_name"
                }, {
                    "control_type": "text",
                    "label": "Last Name",
                    "type": "string",
                    "name": "last_name"
                }, {
                    "control_type": "text-area",
                    "label": "Notes",
                    "type": "string",
                    "name": "notes"
                }, {
                    "control_type": "text",
                    "label": "Address 1",
                    "type": "string",
                    "name": "address_1"
                }, {
                    "control_type": "text",
                    "label": "Address 2",
                    "type": "string",
                    "name": "address_2"
                }, {
                    "control_type": "text",
                    "label": "City",
                    "type": "string",
                    "name": "city"
                }, {
                    "control_type": "text",
                    "label": "Province",
                    "type": "string",
                    "name": "province"
                }, {
                    "control_type": "text",
                    "label": "Postal Code",
                    "type": "string",
                    "name": "postal_code"
                }, {
                    "control_type": "text",
                    "label": "Country",
                    "type": "string",
                    "name": "country"
                }, {
                    "control_type": "phone",
                    "label": "Telephone",
                    "type": "string",
                    "name": "telephone"
                }, {
                    "control_type": "phone",
                    "label": "Fax",
                    "type": "string",
                    "name": "fax"
                }, {
                    "control_type": "url",
                    "label": "URL",
                    "type": "string",
                    "name": "url"
                }, {
                    "control_type": "text",
                    "label": "Business Number",
                    "type": "string",
                    "name": "business_number"
                }, {
                    "control_type": "text",
                    "label": "Locale",
                    "type": "string",
                    "name": "locale",
                    "hint": "Customer language, based on ISO 639-1 standard. For example, 'en', 'fr', or 'es'."
                }, {
                    "control_type": "text",
                    "label": "Parent Identifier",
                    "type": "string",
                    "name": "parent_identifier"
                }, {
                    "control_type": "text",
                    "label": "PDF Attachment Opt-In",
                    "type": "boolean",
                    "name": "pdf_attachment_opt_in",
                    "hint": "Boolean field, valid values are 'true' or 'false'"
                }, {
                    "control_type": "text",
                    "label": "Account Status",
                    "type": "string",
                    "name": "account_status",
                    "hint": "Valid values are 'open', 'closed', or 'on_hold'."
                }, {
                    "control_type": "date",
                    "label": "Last Contact Date",
                    "type": "date",
                    "name": "last_contact_date"
                }, {
                    "control_type": "date",
                    "label": "Next Contact Date",
                    "type": "date",
                    "name": "next_contact_date"
                }, {
                    "control_type": "number",
                    "label": "Credit Limit (in cents)",
                    "type": "integer",
                    "name": "credit_limit_cents",
                    "hint": "The customer's credit limit. This is the maximum value of outstanding invoices before the supplier is alerted, if supplier is configured to monitor this. If the customer is a multi-currency customer, this is the total credit limit converted to a single currency."
                }, {
                    "control_type": "text",
                    "label": "Credit Limit Currency",
                    "type": "string",
                    "name": "credit_limit_currency",
                    "hint": "Currency of the credit limit. If blank, defaults to the currency of the majority of the customer's invoices. If there are no invoices, defaults to the supplier’s default currency. For example, 'usd', 'gbp', 'eur', 'cad'."
                }, {
                    "control_type": "text",
                    "label": "Credit Rating",
                    "type": "string",
                    "name": "credit_rating"
                }, {
                    "control_type": "text",
                    "label": "Terms Type",
                    "type": "string",
                    "name": "terms_type",
                    "hint": "This field and terms_value specify how to set a customer's due date. Valid values are 'date' or 'day'."
                }, {
                    "control_type": "number",
                    "label": "Terms Value",
                    "type": "integer",
                    "name": "terms_value",
                    "hint": "If terms_type is 'day': It means the due date should be <terms_value> days after invoice date. E.g. if terms_value is 30, the due date must be 30 days after the invoice date. It must be a whole number between 0 and 100. If terms_type is 'date': It means the due date is on a fixed day (terms_value) of the month. E.g. if terms_value is 15, it means the due date should be on the 15th of the month after invoice date. It must be an integer between 1 and 27 inclusive, or -1 to specify the last day of the month, or -2 to specify the second-last day of the month."
                }, {
                    "control_type": "text-area",
                    "label": "Company bio",
                    "type": "string",
                    "name": "company_bio"
                }, {
                    "control_type": "text",
                    "label": "Ignores CC Payment Rules",
                    "type": "boolean",
                    "name": "ignores_cc_payment_rules",
                    "hint": "Boolean field, valid values are 'true' or 'false'"
                }, {
                    "control_type": "text",
                    "label": "Tags",
                    "type": "string",
                    "name": "tags"
                }, {
                    "control_type": "text",
                    "label": "External ID",
                    "type": "string",
                    "name": "external_id"
                }, {
                    "control_type": "text",
                    "label": "Suppress all notifications from VersaPay ARC?",
                    "type": "boolean",
                    "name": "notification_suppressed"
                }, {
                    "name": "line_item_attributes",
                    "type": "array",
                    "of": "object",
                    "label": "Line item attributes",
                    "properties": [{
                        "control_type": "email",
                        "label": "Email",
                        "type": "string",
                        "name": "email"
                    }, {
                        "control_type": "text",
                        "label": "First Name",
                        "type": "string",
                        "name": "first_name"
                    }, {
                        "control_type": "text",
                        "label": "Last Name",
                        "type": "string",
                        "name": "last_name"
                    }, {
                        "control_type": "text",
                        "label": "Title",
                        "type": "string",
                        "name": "title"
                    }, {
                        "control_type": "text",
                        "label": "Department",
                        "type": "string",
                        "name": "department"
                    }, {
                        "control_type": "phone",
                        "label": "Telephone",
                        "type": "string",
                        "name": "telephone"
                    }, {
                        "control_type": "text",
                        "label": "Is User Activated?",
                        "type": "boolean",
                        "name": "bulk_activate"
                    }]
                }]
            }
        },
        invoice_view: {
            fields: -> () {
                [{
                    "control_type": "text",
                    "label": "Number",
                    "type": "string",
                    "name": "number"
                }, {
                    "control_type": "text",
                    "label": "Display Number",
                    "type": "string",
                    "name": "display_number"
                }, {
                    "control_type": "text",
                    "label": "Currency",
                    "type": "string",
                    "name": "currency"

                }, {
                    "control_type": "number",
                    "label": "Amount (in cents)",
                    "type": "integer",
                    "name": "amount_cents"
                }, {
                    "control_type": "text",
                    "label": "Subtotal Tax 1",
                    "type": "string",
                    "name": "subtotal_tax1"
                }, {
                    "control_type": "text",
                    "label": "Subtotal Tax 2",
                    "type": "string",
                    "name": "subtotal_tax2"
                }, {
                    "control_type": "text",
                    "label": "Customer Identifier",
                    "type": "string",
                    "name": "customer_identifier"
                }, {
                    "control_type": "date",
                    "label": "Date",
                    "type": "string",
                    "name": "date",
                    "hint": "YYYY-MM-DD"
                }, {
                    "control_type": "date",
                    "label": "Order date",
                    "type": "string",
                    "name": "order_date",
                    "hint": "YYYY-MM-DD"
                }, {
                    "control_type": "date",
                    "label": "Due date",
                    "type": "string",
                    "name": "due_date",
                    "hint": "YYYY-MM-DD"
                }, {
                    "control_type": "text",
                    "label": "Purchase Order Number",
                    "type": "string",
                    "name": "purchase_order_number"
                }, {
                    "control_type": "text-area",
                    "label": "Notes Text",
                    "type": "string",
                    "name": "notes_text"
                }, {
                    "control_type": "text",
                    "label": "Shipping Name",
                    "type": "string",
                    "name": "shipping_name"
                }, {
                    "label": "Shipping Address",
                    "type": "object",
                    "name": "shipping_address",
                    "properties": [{
                        "control_type": "text",
                        "label": "Address 1",
                        "type": "string",
                        "name": "address_1"
                    }, {
                        "control_type": "text",
                        "label": "Address 2",
                        "type": "string",
                        "name": "address_2"
                    }, {
                        "control_type": "text",
                        "label": "City",
                        "type": "string",
                        "name": "city"
                    }, {
                        "control_type": "text",
                        "label": "State",
                        "type": "string",
                        "name": "state"
                    }, {
                        "control_type": "text",
                        "label": "Country",
                        "type": "string",
                        "name": "country"
                    }, {
                        "control_type": "text",
                        "label": "Country Name",
                        "type": "string",
                        "name": "country_name"
                    }, {
                        "control_type": "text",
                        "label": "Zip",
                        "type": "string",
                        "name": "zip"
                    }, {
                        "control_type": "text",
                        "label": "Line 1",
                        "type": "string",
                        "name": "line_1",
                        "hint": "Single line combining shipping address_1 and address_2."
                    }, {
                        "control_type": "text",
                        "label": "Line 2",
                        "type": "string",
                        "name": "line_2",
                        "hint": "Single line combining shipping city, state and zip."
                    }]
                }, {
                    "name": "line_item_attributes",
                    "type": "array",
                    "of": "object",
                    "label": "Line Item Attributes",
                    "properties": [{
                        "control_type": "text",
                        "label": "Number",
                        "type": "string",
                        "name": "number"
                    }, {
                        "control_type": "text",
                        "label": "Description",
                        "type": "string",
                        "name": "description"
                    }, {
                        "control_type": "number",
                        "label": "Quantity",
                        "parse_output": "float_conversion",
                        "type": "number",
                        "name": "quantity"
                    }, {
                        "control_type": "number",
                        "label": "Unit Cost (in cents)",
                        "type": "integer",
                        "name": "unit_cost_cents"
                    }, {
                        "control_type": "number",
                        "label": "Amount (in cents)",
                        "type": "integer",
                        "name": "amount_cents"
                    }, {
                        "control_type": "number",
                        "label": "Balance (in cents)",
                        "type": "integer",
                        "name": "balance_cents"
                    }, {
                        "control_type": "number",
                        "label": "ID",
                        "parse_output": "float_conversion",
                        "type": "number",
                        "name": "id"
                    }, {
                        "control_type": "text",
                        "label": "Identifier",
                        "type": "string",
                        "name": "identifier"
                    }, {
                        "control_type": "number",
                        "label": "Invoice ID",
                        "parse_output": "float_conversion",
                        "type": "number",
                        "name": "invoice_id"
                    }, {
                        "control_type": "text",
                        "label": "Purchase Order Number",
                        "type": "string",
                        "name": "purchase_order_number"
                    }, {
                        "control_type": "text",
                        "label": "Order Key",
                        "type": "string",
                        "name": "order_key"
                    }, {
                        "control_type": "text",
                        "label": "Recurring Invoice ID",
                        "type": "string",
                        "name": "recurring_invoice_id"
                    }, {
                        "label": "Extended Attributes",
                        "type": "object",
                        "name": "extended_attributes",
                        "hint": "Additional non-standard attribute stored with the line-item record for presentment rendering.",
                        "properties": [{
                            "control_type": "text",
                            "label": "Key",
                            "type": "string",
                            "name": "key",
                            "hint": "Key-value pair of the extended attribute on the line-item."
                        }]
                    }]
                }, {
                    "control_type": "checkbox",
                    "label": "Auto Debit",
                    "type": "boolean",
                    "name": "auto_debit"
                }, {
                    "control_type": "text",
                    "label": "Division",
                    "type": "string",
                    "name": "division"
                }, {
                    "control_type": "text",
                    "label": "Auto Pay Reference",
                    "type": "string",
                    "name": "auto_pay_reference"
                }, {
                    "control_type": "number",
                    "label": "Owing (in cents)",
                    "type": "integer",
                    "name": "owing_cents"
                }, {
                    "control_type": "text",
                    "label": "Status",
                    "type": "string",
                    "name": "status",
                    "hint": "The status of the invoice in ARC. Can be one of DRAFT, CURRENT, OVERDUE, PARTIAL, PAID, CREDIT or CLOSED",
                    "pick_list": [
                        ["DRAFT", "DRAFT"],
                        ["CURRENT", "CURRENT"],
                        ["OVERDUE", "OVERDUE"],
                        ["PARTIAL", "PARTIAL"],
                        ["PAID", "PAID"],
                        ["CREDIT", "CREDIT"],
                        ["CLOSED", "CLOSED"]
                    ]
                }, {
                    "control_type": "select",
                    "label": "Delivery Status",
                    "type": "string",
                    "name": "delivery_status",
                    "hint": "The delivery status of the invoice in ARC. Statuses in the API map to those in the UI as follows: 'new' (Not Tracked), 'not_sent' (Available), 'sent' (Email Sent), 'delivery_unknown' (Delivery Unknown), 'not_delivered', (Not Delivered), 'delivered' (Email Delivered), 'opened' (Email Opened), 'clicked' (Viewed).",
                    "pick_list": [
                        ["Not Tracked", "new"],
                        ["Available", "not_sent"],
                        ["Email Sent", "sent"],
                        ["Delivery Unknown", "delivery_unknown"],
                        ["Not Delivered", "not_delivered"],
                        ["Email Delivered", "delivered"],
                        ["Email Opened", "opened"],
                        ["Viewed", "clicked"]

                    ]
                }, {
                    "control_type": "text",
                    "label": "Ref 1",
                    "type": "string",
                    "name": "ref1"
                }, {
                    "control_type": "text",
                    "label": "Ref 2",
                    "type": "string",
                    "name": "ref2"
                }, {
                    "control_type": "text",
                    "label": "Ref 3",
                    "type": "string",
                    "name": "ref3"
                }, {
                    "name": "adjustments_attributes",
                    "type": "array",
                    "of": "object",
                    "label": "Adjustments Attributes",
                    "hint": "Adjustments such as Fuel Surcharge or Discount on the invoice.",
                    "properties": [{
                        "control_type": "text",
                        "label": "Label",
                        "type": "string",
                        "name": "label"
                    }, {
                        "control_type": "number",
                        "label": "Amount (in cents)",
                        "type": "integer",
                        "name": "amount_cents"
                    }, {
                        "control_type": "number",
                        "label": "ID",
                        "type": "integer",
                        "name": "id"
                    }, {
                        "control_type": "number",
                        "label": "Invoice ID",
                        "type": "integer",
                        "name": "invoice_id"
                    }, {
                        "control_type": "number",
                        "label": "Recurring Invoice ID",
                        "type": "integer",
                        "name": "recurring_invoice_id"
                    }]
                }, {
                    "control_type": "text",
                    "label": "Plan Identifier",
                    "type": "string",
                    "name": "plan_identifier"
                }, {
                    "control_type": "date",
                    "label": "Plan Start Date",
                    "type": "date",
                    "name": "plan_start_date"
                }, {
                    "control_type": "text",
                    "label": "Plan End Date",
                    "type": "string",
                    "name": "plan_end_date"
                }, {
                    "control_type": "number",
                    "label": "Plan Payment Amount (in cents)",
                    "type": "integer",
                    "name": "plan_payment_amount_cents"
                }, {
                    "control_type": "number",
                    "label": "Annualized Amount (in cents)",
                    "type": "integer",
                    "name": "annualized_amount_cents"
                }, {
                    "control_type": "date",
                    "label": "Annualized Effective Date",
                    "type": "string",
                    "name": "annualized_effective_date"
                }, {
                    "control_type": "date",
                    "label": "Annualized Expiry Date",
                    "type": "string",
                    "name": "annualized_expiry_date"
                }, {
                    "control_type": "text",
                    "label": "External ID",
                    "type": "string",
                    "name": "external_id"
                }, {
                    "label": "Extended Attributes",
                    "type": "object",
                    "name": "extended_attributes",
                    "hint": "Additional non-standard attribute stored with the invoice record for presentment rendering.",
                    "properties": [{
                        "control_type": "text",
                        "label": "Key",
                        "type": "string",
                        "name": "key"
                    }]
                }]
            }
        },
        invoice_edit: {
            fields: -> () {
                [{
                    "control_type": "text",
                    "label": "Number",
                    "type": "string",
                    "name": "number",
                    "optional": false
                }, {
                    "control_type": "text",
                    "label": "Display Number",
                    "type": "string",
                    "name": "display_number"
                }, {
                    "control_type": "text",
                    "label": "Currency",
                    "type": "string",
                    "name": "currency",
                    "hint": "Currency code, based on ISO-4217. E.g. CAD, USD, AUD"
                }, {
                    "control_type": "number",
                    "label": "Amount (in cents)",
                    "type": "integer",
                    "name": "amount",
                    "hint": "The invoice amount in cents."
                }, {
                    "control_type": "number",
                    "label": "Subtotal (in cents)",
                    "type": "integer",
                    "name": "subtotal1",
                    "hint": "Sub total amount in cents."
                }, {
                    "control_type": "number",
                    "label": "Tax (in cents)",
                    "type": "integer",
                    "name": "tax1",
                    "hint": "This is an extended attribute so that we can show locale specific currency for tax."
                }, {
                    "control_type": "number",
                    "label": "Subtotal Tax 1 (in cents)",
                    "type": "integer",
                    "name": "subtotal_tax1",
                    "hint": "Tax amount in cents. "
                }, {
                    "control_type": "number",
                    "label": "Subtotal Tax 2 (in cents)",
                    "type": "integer",
                    "name": "subtotal_tax2",
                    "hint": "Additional field to carry tax amount (in cents). For example, when invoice shows state (provincial) and federal taxes."
                }, {
                    "control_type": "text",
                    "label": "Customer Identifier",
                    "type": "string",
                    "name": "customer_identifier",
                    "optional": false
                }, {
                    "control_type": "date",
                    "label": "Date",
                    "type": "date",
                    "name": "date",
                    "hint": "Invoice date, YYYY-MM-DD, based on ISO-8601."
                }, {
                    "control_type": "date",
                    "label": "Order Date",
                    "type": "date",
                    "name": "order_date",
                    "hint": "Format is YYYY-MM-DD"
                }, {
                    "control_type": "date",
                    "label": "Due Date",
                    "type": "date",
                    "name": "due_date",
                    "hint": "Format is YYYY-MM-DD"
                }, {
                    "control_type": "text",
                    "label": "Purchase Order Number",
                    "type": "string",
                    "name": "purchase_order_number"
                }, {
                    "control_type": "text-area",
                    "label": "Notes Text",
                    "type": "string",
                    "name": "notes_text"
                }, {
                    "control_type": "text",
                    "label": "Shipping Attention",
                    "type": "string",
                    "name": "shipping_attention"
                }, {
                    "control_type": "text",
                    "label": "Shipping Name",
                    "type": "string",
                    "name": "shipping_name"
                }, {
                    "control_type": "text",
                    "label": "Shipping Address 1",
                    "type": "string",
                    "name": "shipping_address_1"
                }, {
                    "control_type": "text",
                    "label": "Shipping Address 2",
                    "type": "string",
                    "name": "shipping_address_2"
                }, {
                    "control_type": "text",
                    "label": "Shipping City",
                    "type": "string",
                    "name": "shipping_city"
                }, {
                    "control_type": "text",
                    "label": "Shipping Province",
                    "type": "string",
                    "name": "shipping_province"
                }, {
                    "control_type": "text",
                    "label": "Shipping Postal Code",
                    "type": "string",
                    "name": "shipping_postal_code"
                }, {
                    "control_type": "text",
                    "label": "Shipping Country",
                    "type": "string",
                    "name": "shipping_country"
                }, {
                    "name": "line_item_attributes",
                    "type": "array",
                    "of": "object",
                    "label": "Line Item Attributes",
                    "hint": "Details of each line-item for the invoice. Any additional non-standard attribute will be stored with the line-item record and available for presentment rendering.",
                    "properties": [{
                        "control_type": "text",
                        "label": "Number",
                        "type": "string",
                        "name": "number"
                    }, {
                        "control_type": "text",
                        "label": "Item",
                        "type": "string",
                        "name": "item"
                    }, {
                        "control_type": "text-area",
                        "label": "Description",
                        "type": "string",
                        "name": "description"
                    }, {
                      "control_type": "text",
                      "label": "Order Key",
                      "type": "string",
                      "name": "order_key",
                      "hint": "Sequence number for the line-item to order-by when rendering on the invoice."
                    }, {
                        "control_type": "text",
                        "label": "Purchase Order Number",
                        "type": "string",
                        "name": "purchase_order_number",
                        "hint": "Purchase order number at the line-item level."
                    }, {
                        "control_type": "number",
                        "label": "Quantity",
                        "parse_output": "float_conversion",
                        "type": "number",
                        "name": "quantity"
                    }, {
                        "control_type": "number",
                        "label": "Unit Cost (in cents)",
                        "type": "integer",
                        "name": "unit_cost_cents"
                    }, {
                        "control_type": "number",
                        "label": "Amount (in cents)",
                        "type": "integer",
                        "name": "amount"
                    }, {
                        "control_type": "number",
                        "label": "Balance (in cents)",
                        "type": "integer",
                        "name": "balance_cents",
                        "hint": "Line-item balance in cents. Applicable if accepting short payments at line-item level."
                    }, {
                        "control_type": "text",
                        "label": "Unit",
                        "type": "string",
                        "name": "unit",
                    }, {
                        "control_type": "text",
                        "label": "Tax Rate",
                        "type": "string",
                        "name": "tax_rate",
                    }, {
                        "control_type": "text",
                        "label": "Start Date",
                        "type": "string",
                        "name": "start_date",
                    }, {
                        "control_type": "text",
                        "label": "End Date",
                        "type": "string",
                        "name": "end_date",
                    }, {
                        "control_type": "text",
                        "label": "Terms",
                        "type": "string",
                        "name": "terms",
                    }, {
                        "control_type": "number",
                        "label": "Net Amount (in cents)",
                        "type": "integer",
                        "name": "net_amount"
                    }, {
                        "control_type": "number",
                        "label": "Discount (in cents)",
                        "type": "integer",
                        "name": "discount"
                    }, {
                        "control_type": "number",
                        "label": "Partner Discount (in cents)",
                        "type": "integer",
                        "name": "partner_discount"
                    }]
                }, {
                    "control_type": "select",
                    "label": "Auto Debit?",
                    "type": "string",
                    "name": "auto_debit",
                    "pick_list": [
                        ["Yes", "Y"],
                        ["No", "N"]
                    ],
                    "hint": "Y (invoice is to be auto-paid if customer has pre-authorized payment) or N (invoice is to be paid manually by customer)"
                }, {
                    "control_type": "text",
                    "label": "Division",
                    "type": "string",
                    "name": "division",
                    "hint": "Division Code. Required only if supplier supports divisions."
                }, {
                    "control_type": "text",
                    "label": "Auto Pay Reference",
                    "type": "string",
                    "name": "auto_pay_reference",
                    "hint": "For AutoPay agreements that reference a policy# or contract#, etc., specify that number."
                }, {
                    "control_type": "number",
                    "label": "Owing (in cents)",
                    "type": "integer",
                    "name": "owing_cents",
                    "hint": "Balance remaining on this invoice or credit memo. Required if supplier is configured for Balance Sync, otherwise ignored."
                }, {
                    "control_type": "number",
                    "label": "Paid (in cents)",
                    "type": "integer",
                    "name": "paid_cents",
                    "hint": "Balance paid on this invoice or credit memo."
                }, {
                    "control_type": "text",
                    "label": "Ref1",
                    "type": "string",
                    "name": "ref1",
                    "hint": "A reference that is meaningful to the customer, e.g. Policy number, contract number, etc."
                }, {
                    "control_type": "text",
                    "label": "Ref2",
                    "type": "string",
                    "name": "ref2",
                    "hint": "A reference that is meaningful to the customer, e.g. Policy number, contract number, etc."
                }, {
                    "control_type": "text",
                    "label": "Ref3",
                    "type": "string",
                    "name": "ref3",
                    "hint": "A reference that is meaningful to the customer, e.g. Policy number, contract number, etc."
                }, {
                    "name": "adjustments_attributes",
                    "type": "array",
                    "of": "object",
                    "label": "Adjustment Attributes",
                    "hint": "Adjustments such as Fuel Surcharge or Discount.",
                    "properties": [{
                        "control_type": "text",
                        "label": "Label",
                        "type": "string",
                        "name": "label"
                    }, {
                        "control_type": "number",
                        "label": "Amount (in cents)",
                        "type": "integer",
                        "name": "amount"
                    }]
                }, {
                    "control_type": "text",
                    "label": "External ID",
                    "type": "string",
                    "name": "external_id",
                    "hint": "Optional external identifier for the invoice to be included in payment exports."
                }, {
                  "control_type": "select",
                  "label": "Is Draft Invoice?",
                  "type": "string",
                  "name": "draft",
                  "hint": "If 'Yes' then the invoice will be set to 'Draft' status.  If 'No' then the invoice will be set to 'Published' (current/overdue/paid) status",
                  "pick_list": [
                      ["Yes", "1"],
                      ["No", "0"]
                  ]
                }, {
                    "control_type": "text",
                    "label": "Terms",
                    "type": "string",
                    "name": "terms"
                }, {
                    "control_type": "text",
                    "label": "Billing Attention",
                    "type": "string",
                    "name": "billing_attention"
                }, {
                    "control_type": "text",
                    "label": "Billing Name",
                    "type": "string",
                    "name": "billing_name"
                }, {
                    "control_type": "text",
                    "label": "Billing Address 1",
                    "type": "string",
                    "name": "billing_address_1"
                }, {
                    "control_type": "text",
                    "label": "Billing Address 2",
                    "type": "string",
                    "name": "billing_address_2"
                }, {
                    "control_type": "text",
                    "label": "Billing City",
                    "type": "string",
                    "name": "billing_city"
                }, {
                    "control_type": "text",
                    "label": "Billing Province",
                    "type": "string",
                    "name": "billing_province"
                }, {
                    "control_type": "text",
                    "label": "Billing Postal Code",
                    "type": "string",
                    "name": "billing_postal_code"
                }, {
                    "control_type": "text",
                    "label": "Billing Country",
                    "type": "string",
                    "name": "billing_country"
                }, {
                    "control_type": "text",
                    "label": "Sales Rep",
                    "type": "string",
                    "name": "sales_rep"
                }, {
                    "control_type": "text",
                    "label": "Start Date",
                    "type": "string",
                    "name": "start_date"
                }, {
                    "control_type": "text",
                    "label": "End Date",
                    "type": "string",
                    "name": "end_date"
                }, {
                    "control_type": "text",
                    "label": "VAT (GBP)",
                    "type": "string",
                    "name": "vat_gbp"
                }, {
                    "control_type": "text",
                    "label": "VAT (GBP) Text",
                    "type": "string",
                    "name": "vat_gbp_text"
                }, {
                    "control_type": "text",
                    "label": "VAT Dynamic Disclaimer",
                    "type": "string",
                    "name": "vat_dynamic_disclaimer"
                }, {
                    "control_type": "text",
                    "label": "VAT Number",
                    "type": "string",
                    "name": "vat_number"
                }, {
                    "control_type": "text",
                    "label": "SF Billing Schedule",
                    "type": "string",
                    "name": "sf_billing_schedule"
                }, {
                    "control_type": "text",
                    "label": "SF Billing Schedule Notes",
                    "type": "string",
                    "name": "sf_billing_schedule_notes"
                }, {
                    "control_type": "text",
                    "label": "Wire Payment Info",
                    "type": "string",
                    "name": "wire_payment_info"
                }, {
                    "control_type": "text",
                    "label": "Shipping Cost",
                    "type": "string",
                    "name": "shipping_cost"
                }, {
                    "control_type": "text",
                    "label": "Discount",
                    "type": "string",
                    "name": "discount"
                }, {
                    "control_type": "text",
                    "label": "Auto-Renewal",
                    "type": "string",
                    "name": "auto_renewal",
                    "hint": "Is this invoice an auto-renewal invoice?"
                }, {
                    "control_type": "text",
                    "label": "Type",
                    "type": "string",
                    "name": "type",
                    "hint": "standard, 1price"
                }]
            }
        },
      payment_view: {
                fields: -> () {
                  [{
                    "control_type": "text",
                    "label": "Payment Reference",
                    "type": "string",
                    "name": "payment_reference"
                   }, {
                    "control_type": "date",
                    "label": "Date",
                    "type": "string",
                    "name": "date",
                   "hint": "Format is YYYY-MM-DD"
                   }, {
                    "control_type": "text",
                    "label": "Payment Amount",
                    "type": "String",
                    "name": "payment_amount",
                    "hint": "The amount of the total payment, excluding fees."
                   },{
                    "label": "Payment Transaction Amount",
                    "type": "String",
                    "name": "payment_transaction_amount",
                    "hint": "The amount of the total payment, including fees."
                   },{
                    "control_type": "text",
                    "label": "Payment Method",
                    "type": "String",
                    "name": "payment_method"
                   }, {
                  "control_type": "select",
                  "label": "Auto Debit?",
                  "type": "string",
                  "name": "auto_debit_indicator",
                  "pick_list": [
                      ["Yes", "Y"],
                      ["No", "N"]
                  ],
                  "hint": "Y if the payment was made via AutoPay agreement"
              },{
                    "control_type": "text",
                    "label": "Payment Timestamp",
                    "type": "String",
                    "name": "payment_timestamp",
                    "hint": "The ISO8601 timestamp corresponding to payment."
                   },{
                  "control_type": "text",
                  "label": "Customer Identifier",
                  "type": "String",
                  "name": "customer_identifier"
                 },{
                  "control_type": "text",
                  "label": "Customer Name",
                  "type": "String",
                  "name": "customer_name"
                 },{
                    "control_type": "text",
                    "label": "Status",
                    "type": "String",
                    "name": "status"
                   },{
                  "control_type": "text",
                  "label": "Payment Source",
                  "type": "String",
                  "name": "payment_source"
                 },{
                  "control_type": "text",
                  "label": "Payment Code",
                  "type": "String",
                  "name": "payment_code",
                  "hint": "The back office payment code (applicable to externally sourced payments)."
                 },{
                  "control_type": "text",
                  "label": "Payment Description",
                  "type": "String",
                  "name": "payment_description",
                    "hint": "The back office payment description (applicable to externally sourced payments)."
                                    },{
                  "control_type": "text",
                  "label": "Gateway Authorization Code",
                  "type": "String",
                  "name": "gateway_authorization_code"
                 },{
                  "control_type": "text",
                  "label": "Pay-To Bank Account",
                  "type": "String",
                  "name": "pay_to_bank_account",
                  "hint": "The GL number of the settlement account receiving the payment."
                 },{
                  "control_type": "text",
                  "label": "Pay-To Bank Account Name",
                  "type": "String",
                  "name": "pay_to_bank_account_name",
                  "hint": "The display name of the settlement account receiving the payment."
                 }, {
                    "name": "payment_amounts",
                    "type": "array",
                    "of": "object",
                    "label": "Payment Amounts",
                    "hint": "Payments applied to invoices and line-items.",
                    "properties": [{
                        "control_type": "text",
                        "label": "Payment Reference",
                        "type": "string",
                        "name": "payment_reference"
                    }, {
                        "control_type": "text",
                        "label": "Invoice Number",
                        "type": "string",
                        "name": "invoice_number",
                        "hint": "The display number of the invoice for which the payment was made."
                    }, {
                        "control_type": "date",
                        "label": "Date",
                        "type": "date",
                        "name": "date",
                        "hint": "The payment date, in YYYY-MM-DD format."
                    }, {
                        "control_type": "text",
                        "label": "Amount",
                        "type": "string",
                        "name": "amount",
                        "hint": "The amount of the payment applied to the invoice, in dollars and cents."
                    }, {
                        "control_type": "text",
                        "label": "Plan Fee",
                        "type": "string",
                        "name": "plan_fee",
                        "hint": "Payment plan fee amount, in dollars and cents, associated to this invoice."
                    }, {
                      "control_type": "text",
                      "label": "Payment Amount",
                      "type": "string",
                      "name": "payment_amount",
                      "hint": "The amount of the total payment, excluding fees."
                  }, {
                      "control_type": "text",
                      "label": "Payment Transaction Amount",
                      "type": "string",
                      "name": "payment_transaction_amount",
                      "hint": "The amount of the total payment, including fees."
                  }, {
                      "control_type": "text",
                      "label": "Payment Transaction Token",
                      "type": "string",
                      "name": "payment_transaction_token"
                  } , {
                      "control_type": "text",
                      "label": "Payment Method",
                      "type": "string",
                      "name": "payment_method"
                  } , {
                      "control_type": "text",
                      "label": "Payment from Bank Account?",
                      "type": "string",
                      "name": "payment_from_bank_account",
                      "hint": "true if the payment was made using a bank account."
                  } , {
                      "control_type": "text",
                      "label": "Payment  from Credit Card?",
                      "type": "string",
                      "name": "payment_from_credit_card",
                      "hint": "The amount of the total payment, including fees."
                  } , {
                      "control_type": "text",
                      "label": "Payment Institution Name",
                      "type": "string",
                      "name": "payment_institution_name",
                      "hint": "Institution name, if the payment was made using a bank account."
                  } , {
                      "control_type": "text",
                      "label": "Payment Credit Card Brand",
                      "type": "string",
                      "name": "payment_credit_card_brand",
                      "hint": "Credit card 'association brand', if the payment was made using a credit card. Example: VISA, MASTER"
                  } , {
                      "control_type": "text",
                      "label": "Short Pay Indicator",
                      "type": "string",
                      "name": "short_pay_indicator",
                      "hint": "Y if a short payment was made."
                  } , {
                      "control_type": "text",
                      "label": "Payment Note",
                      "type": "string",
                      "name": "payment_note"
                  } , {
                      "control_type": "text",
                      "label": "Auto Debit Indicator",
                      "type": "string",
                      "name": "auto_debit_indicator",
                      "hint": "Y if the payment was made via AutoPay agreement."
                  } , {
                      "control_type": "text",
                      "label": "Invoice Balance",
                      "type": "string",
                      "name": "invoice_balance",
                      "hint": "Remaining balance on the invoice (after the payment is processed)."
                  } , {
                      "control_type": "text",
                      "label": "Payment Timestamp",
                      "type": "string",
                      "name": "payment_timestamp",
                      "hint": "The ISO8601 timestamp corresponding to payment."
                  } , {
                      "control_type": "text",
                      "label": "Invoice Division",
                      "type": "string",
                      "name": "invoice_division"
                  } , {
                      "control_type": "text",
                      "label": "Invoice Divison Number",
                      "type": "string",
                      "name": "invoice_division_number"
                  } , {
                      "control_type": "text",
                      "label": "Invoice Division Name",
                      "type": "string",
                      "name": "invoice_division_name"
                  }  , {
                      "control_type": "text",
                      "label": "Pay-To Bank Account",
                      "type": "string",
                      "name": "pay_to_bank_account",
                      "hint": "The GL number of the settlement account receiving the payment."
                  }   , {
                      "control_type": "text",
                      "label": "Pay-To Bank Account Name",
                      "type": "string",
                      "name": "pay_to_bank_account_name",
                      "hint": "The display name of the settlement account receiving the payment."
                  }  , {
                      "control_type": "text",
                      "label": "Customer Identifier",
                      "type": "string",
                      "name": "customer_identifier",
                      "hint": ""
                  }  , {
                      "control_type": "text",
                      "label": "Customer Name",
                      "type": "string",
                      "name": "customer_name",
                      "hint": ""
                  }  , {
                      "control_type": "text",
                      "label": "Status",
                      "type": "string",
                      "name": "status",
                      "hint": ""
                  }  , {
                      "control_type": "text",
                      "label": "Payment Source",
                      "type": "string",
                      "name": "payment_source",
                      "hint": ""
                  }  , {
                      "control_type": "text",
                      "label": "Payment Code",
                      "type": "string",
                      "name": "payment_code",
                      "hint": "The back office payment code (applicable to externally sourced payments)."
                  }  , {
                      "control_type": "text",
                      "label": "Payment Description",
                      "type": "string",
                      "name": "payment_description",
                      "hint": "The back office payment description (applicable to externally sourced payments)."
                  }  , {
                      "control_type": "text",
                      "label": "Gateway Authorization Code",
                      "type": "string",
                      "name": "gateway_authorization_code",
                      "hint": "The underlying gateway authorization code."
                  }  , {
                      "control_type": "text",
                      "label": "Purchase Order Number",
                      "type": "string",
                      "name": "purchase_order_number",
                      "hint": "The purchase order number entered at the time of making a prepayment."
                  }  , {
                      "control_type": "text",
                      "label": "Ref1",
                      "type": "string",
                      "name": "ref1",
                      "hint": "The reference number or string entered at the time of making a prepayment."
                  }   , {
                      "control_type": "text",
                      "label": "Ref2",
                      "type": "string",
                      "name": "ref2",
                      "hint": "The reference number or string entered at the time of making a prepayment."
                  }  , {
                      "control_type": "text",
                      "label": "Ref3",
                      "type": "string",
                      "name": "ref3",
                      "hint": "The reference number or string entered at the time of making a prepayment."
                  } , {
                      "control_type": "text",
                      "label": "Short Pay Reason Identifier",
                      "type": "string",
                      "name": "short_pay_reason_identifier",
                      "hint": ""
                  } , {
                      "control_type": "text",
                      "label": "Short Pay Reason",
                      "type": "string",
                      "name": "short_pay_reason",
                      "hint": ""
                  } , {
                      "control_type": "text",
                      "label": "Invoice Amount Paid",
                      "type": "string",
                      "name": "invoice_amount_paid",
                      "hint": "The total amount of payments, in dollars and cents, made to date via ARC towards this invoice."
                  } , {
                      "control_type": "text",
                      "label": "Invoice Identifier",
                      "type": "string",
                      "name": "invoice_identifier",
                      "hint": ""
                  } , {
                      "control_type": "date",
                      "label": "Invoice Date",
                      "type": "date",
                      "name": "invoice_date",
                      "hint": "Invoice date, in the format YYYY-MM-DD."
                  } , {
                      "control_type": "text",
                      "label": "Invoice External ID",
                      "type": "string",
                      "name": "invoice_external_id",
                      "hint": "The external identifier/reference, if any, of the invoice for which the payment was made."
                  } , {
                      "control_type": "text",
                      "label": "Invoice Currency",
                      "type": "string",
                      "name": "invoice_currency",
                      "hint": ""
                  } , {
                      "control_type": "text",
                      "label": "Invoice Purchase Order Number",
                      "type": "string",
                      "name": "invoice_purchase_order_number",
                      "hint": ""
                  } , {
                      "control_type": "text",
                      "label": "Invoice Ref1",
                      "type": "string",
                      "name": "invoice_ref1",
                      "hint": "Reference number or string associated to the invoice."
                  } , {
                      "control_type": "text",
                      "label": "Invoice Ref2",
                      "type": "string",
                      "name": "invoice_ref2",
                      "hint": "Reference number or string associated to the invoice."
                  } , {
                      "control_type": "text",
                      "label": "Invoice Ref3",
                      "type": "string",
                      "name": "invoice_ref3",
                      "hint": "Reference number or string associated to the invoice."
                  } , {
                      "control_type": "text",
                      "label": "Cumulative Customer Amount",
                      "type": "string",
                      "name": "cumulative_customer_amount",
                      "hint": "The total payment processed for this customer under this payment_reference."
                  } , {
                      "name": "line_item_transactional_amounts",
                      "type": "array",
                      "of": "object",
                      "label": "Line Item Transactional Amounts",
                      "hint": "Payments applied to invoice line-items. Applicable if accepting short payments at line-item level.",
                      "properties": [{
                          "control_type": "text",
                          "label": "Line Item Number",
                          "type": "string",
                          "name": "line_item_number"
                      }, {
                          "control_type": "text",
                          "label": "Line Item Payment Amount",
                          "type": "string",
                          "name": "line_item_payment_amount",
                          "hint": "The amount of the payment applied to the line-item, in dollars and cents."
                      }, {
                        "control_type": "text",
                        "label": "Line Item Balance",
                        "type": "string",
                        "name": "line_item_balance",
                        "hint": "Remaining balance on the line-item (after the payment is processed), in dollars and cents."
                    }, {
                        "control_type": "text",
                        "label": "Line Item Short Pay Indicator",
                        "type": "string",
                        "name": "line_item_short_pay_indicator",
                        "hint": "Y if a short payment was made."
                    } , {
                        "control_type": "text",
                        "label": "Line Item Payment Note",
                        "type": "string",
                        "name": "line_item_payment_note"
                    } , {
                        "control_type": "text",
                        "label": "Line Item Short Pay Reason Identifier",
                        "type": "string",
                        "name": "line_item_short_pay_reason_identifier"
                    } , {
                        "control_type": "text",
                        "label": "Line Item Short Pay Reason",
                        "type": "string",
                        "name": "line_item_short_pay_reason"
                    } , {
                        "control_type": "text",
                        "label": "Line Item Dispute Reason",
                        "type": "string",
                        "name": "line_item_dispute_reason"
                    }  ]
                  }
                    
                  ]
                }
                   ]
                }
            },
        file_import: {
          fields: -> () {
            [
              {
                "control_type": "text",
                "label": "File",
                "type": "string",
                "name": "file",
                "optional": false
              },
              {
                "control_type": "text",
                "label": "File Name",
                "type": "string",
                "name": "filename",
                "optional": false
              }
            ]
          }
        },
        payment_edit: {
                  fields: -> () {
                    [{
                      "control_type": "text",
                      "label": "Identifier",
                      "type": "string",
                      "name": "identifier",
                      "optional": false
                     },
                      {
                                            "control_type": "number",
                                            "label": "Amount",
                                            "type": "integer",
                                            "name": "amount",
                                            "hint": "The amount of total payment, in cents."
                                           },
                      {
                                            "control_type": "date",
                                            "label": "Date",
                                            "type": "date",
                                            "name": "date",
                        "hint": "Format is YYYY-MM-DD"
                                           }, {
                      "control_type": "text",
                      "label": "Currency",
                      "type": "String",
                      "name": "currency"
                     },{
                      "control_type": "text",
                      "label": "Invoice Number",
                      "type": "String",
                      "name": "invoice_number",
                      "hint": "Invoice number associated with this payment (if payment covers single invoice). If payment covers multiple invoices, provide payment_amount_attributes instead."
                     },{
                      "control_type": "text",
                      "label": "Payment Code",
                      "type": "String",
                      "name": "payment_code"
                     },{
                      "control_type": "text",
                      "label": "Payment Description",
                      "type": "String",
                      "name": "payment_description"
                     }, {
                      "name": "payment_amounts_attributes",
                      "type": "array",
                      "of": "object",
                      "label": "Payment Amounts Attributes",
                      "hint": "Applicable only when payment covers multiple invoices.",
                      "properties": [{
                          "control_type": "text",
                          "label": "Invoice Number",
                          "type": "string",
                          "name": "invoice_number"
                      }, {
                          "control_type": "number",
                          "label": "Amount",
                          "type": "integer",
                          "name": "amount",
                          "hint": "The amount of total payment, in cents."
                      }, {
                          "control_type": "text-area",
                          "label": "Notes",
                          "type": "string",
                          "name": "notes"
                      }, {
                          "control_type": "text",
                          "label": "Purchase Order Number",
                          "type": "string",
                          "name": "purchase_order_number",
                          "hint": "Purchase order number to link this payment to an invoice."
                      }, {
                          "control_type": "text",
                          "label": "Ref1",
                          "type": "string",
                          "name": "ref1",
                          "hint": "An additional reference number that could link this payment to an invoice. E.g. policy number, contract number, etc."
                      }, {
                        "control_type": "text",
                        "label": "Ref2",
                        "type": "string",
                        "name": "ref2",
                        "hint": "An additional reference number that could link this payment to an invoice. E.g. policy number, contract number, etc."
                    }, {
                        "control_type": "text",
                        "label": "Ref3",
                        "type": "string",
                        "name": "ref3",
                        "hint": "An additional reference number that could link this payment to an invoice. E.g. policy number, contract number, etc."
                    } ]
                  },{
                      "control_type": "text",
                      "label": "Division",
                      "type": "String",
                      "name": "division",
                      "hint": "Division code, if divisions are set up."
                     },{
                      "control_type": "text",
                      "label": "Customer Identifier",
                      "type": "String",
                      "name": "customer_identifier"
                     },{
                      "control_type": "text",
                      "label": "Customer Name",
                      "type": "String",
                      "name": "customer_name"
                     }
                     ]
                  }
              }
             
    },

    test: -> (connection) {
        get("#{connection['environment']}/api/imports/processing")
    },

    actions: {
        view_customer: {
            input_fields: -> (object_definitions) {
                object_definitions["customer_view"].only("identifier")
            },
            execute: -> (connection, input) {
                get("#{connection['environment']}/api/exports/customer/#{input['identifier']}").
                after_error_response(/.*/) do |_code, body, _header, message|
                  if _code==404
                    error("404 Not Found: #{body}")
                  else
                    error("#{message}: #{body}")
                  end
                end
            },
            output_fields: -> (object_definitions) {
                object_definitions['customer_view']
            }
        },
        upsert_customer: {
            input_fields: -> (object_definitions) {
                object_definitions["customer_edit"]
            },
            execute: -> (connection, input) {
                post("#{connection['environment']}/api/imports/customer", input).
                after_error_response(/.*/) do |code, body, header, message|
              error("#{message}: #{body}")
          end
            },
            output_fields: -> (object_definitions) {
                object_definitions['generic_created_response']
            }
        },
        view_invoice: {
            input_fields: -> () {
                [{
                    "name": "number_or_id",
                    "optional": false,
                    "hint": "The path parameter number_or_id is matched to the invoice number, display_number, or id, in that order."
                }]
            },
            execute: -> (connection, input) {
                get("#{connection['environment']}/api/exports/invoice/#{input['number_or_id']}").
                after_error_response(/.*/) do |_code, body, _header, message|
                  if _code==404
                    error("404 Not Found: #{body}")
                  else
                    error("#{message}: #{body}")
                  end
                end
            },
            output_fields: -> (object_definitions) {
                object_definitions['invoice_view']
            }
        },
        upsert_invoice: {
            input_fields: -> (object_definitions) {
                object_definitions["invoice_edit"]
            },
            execute: -> (connection, input) {
                #error ("#{input.to_json}")
              
                post("#{connection['environment']}/api/imports/invoice", input).
                after_error_response(/.*/) do |code, body, header, message|
                  error("#{message}: #{body}")
                end
            },
          output_fields: -> (object_definitions) {
                object_definitions['generic_created_response']
            }
        },
        view_payment: {
          input_fields: -> () {
              [{
                  "name": "reference_or_token",
                  "optional": false,
                  "hint": "The payment's payment_reference or payment_transaction_token."
              }]
          },
          execute: -> (connection, input) {
                get("#{connection['environment']}/api/exports/payment/#{input['reference_or_token']}").
                after_error_response(/.*/) do |_code, body, _header, message|
                  if _code==404
                    error("404 Not Found: #{body}")
                  else
                    error("#{message}: #{body}")
                  end
                end
          },
          output_fields: -> (object_definitions) {
              object_definitions['payment_view']
          }
      },
      upsert_payment: {
          input_fields: -> (object_definitions) {
              object_definitions["payment_edit"]
          },
          execute: -> (connection, input) {
              #error ("#{input.to_json}")
            
              post("#{connection['environment']}/api/imports/payment", input).
              after_error_response(/.*/) do |code, body, header, message|
                error("#{message}: #{body}")
              end
          },
          output_fields: -> (object_definitions) {
              object_definitions['generic_created_response']
          }
      },
      import_file: {
        input_fields: lambda do
          [
            { name: "filename", type: "string" },
            { name: "file", type: "string" }
          ]
        end,

        execute: lambda do |connection, input|
          post("#{connection['environment']}/api/imports").
            request_format_multipart_form.
            payload(file: [input['file'], 'text/csv'],
              filename: input['filename'])
        end
      }
    },
 
  triggers: {
=begin
    new_updated_object: {
      title: "New/Updated Object",
        
          input_fields: lambda do
        [
          {
            name: 'type',
            label: "Type",
            control_type: "select",
            pick_list: [
            ["New/Updated Payment", "payment"],["New/Updated Customer", "customer"]
        ],
            optional: false
          }
        ]
      end,
  
      webhook_key: lambda do |connection, input|
        "test"
      end,
  
      webhook_notification: lambda do |connection, payload|
        payload
      end,
  
      output_fields: lambda do |object_definitions|
        object_definitions['payment_view']
      end
    },
=end
    updated_customer: {
      description: "Updated Customer",
    
      input_fields: lambda do
        [
          {
            name: "watermark",
            type: :integer,
            optional: true,
            hint: "If you specify a watermark, it will be used as the starting point to retrieve 
              updated customers (the next updated customer trigger will be the one updated 
              immediately after the customer specified by the watermark)"
          }
        ]
      end,
    
      poll: lambda do |connection, input, watermark|
        page_size = 100
        
        param = {}
        if watermark.present?
          param = { watermark: watermark }
        elsif input["watermark"].present?
          param = { watermark: input["watermark"] }
        end
        
        response = get("#{connection['environment']}/api/exports/customers/recent").params(param)
        
        customers_array = []
        next_watermark = nil
          
        response["customers"].keys.each do |key|
          # extract each of the customer's data from the response
          customer_hash = response["customers"][key]
          # store the watermark so we know where to start for the next page
          customer_watermark = customer_hash["watermark"]
          if !next_watermark.present? || customer_watermark>next_watermark
            next_watermark = customer_watermark
          end
          # add the customer's data to the output for the trigger
          customers_array << customer_hash
        end
    
        {
          events: customers_array,
          next_poll: (next_watermark || watermark),
          can_poll_more: customers_array.length >= page_size
        }
      end,
    
      dedup: lambda do |event|
        event["watermark"]
      end,
    
      output_fields: lambda do |object_definitions|
        object_definitions["customer_view"]
      end
    },
    entered_comment: {
      description: "Entered Customer/Invoice Comment",
    
      input_fields: lambda do
        [
          {
            name: "watermark",
            type: :string,
            optional: true,
            hint: "The starting point for retrieving comments."
          }
        ]
      end,
    
      poll: lambda do |connection, input, watermark|
        page_size = 100
        
        param = {}
        if watermark.present?
          param = { watermark: watermark }
        elsif input["watermark"].present?
          param = { watermark: input["watermark"] }
        end
        
        response = get("#{connection['environment']}/api/exports/comments").params(param)
        
        comments_array = []
        next_watermark = nil
          
        response["comments"].keys.each do |key|
          # extract each of the customer's data from the response
          comment_hash = response["comments"][key]
          # store the watermark so we know where to start for the next page
          comment_watermark = key
          # add the watermark to the comment record
          comment_hash["watermark"] = comment_watermark
          if !next_watermark.present? || comment_watermark>next_watermark
            next_watermark = comment_watermark
          end
          # add the customer's data to the output for the trigger
          comments_array << comment_hash
        end
    
        {
          events: comments_array,
          next_poll: (next_watermark || watermark),
          can_poll_more: comments_array.length >= page_size
        }
      end,
    
      dedup: lambda do |event|
        event["identifier"]
      end,
    
      output_fields: lambda do |object_definitions|
        [
          { name: "customer_identifier", label: "Customer Identifier" },
          { name: "customer_name", label: "Customer Name" },
          { name: "regarding", label: "Regarding" },
          { name: "target_users", label: "Target Users" },
          { name: "dispute", label: "Is Dispute" },
          { name: "internal", label: "Is Internal" },
          { name: "timestamp", label: "Timestamp" },
          { name: "user", label: "User" },
          { name: "email", label: "Email" },
          { name: "organization", label: "Organization Name" },
          { name: "comment", label: "Comment" },
          { name: "watermark", label: "Watermark" }
        ]
      end
    },
    opened_or_closed_dispute: {
      description: "Opened/Closed Dispute",
    
      input_fields: lambda do
        [
          {
            name: "watermark",
            type: :string,
            optional: true,
            hint: "The starting point for retrieving disputes."
          }
        ]
      end,
    
      poll: lambda do |connection, input, watermark|
        page_size = 100
        
        param = {}
        if watermark.present?
          param = { watermark: watermark }
        elsif input["watermark"].present?
          param = { watermark: input["watermark"] }
        end
        
        response = get("#{connection['environment']}/api/exports/disputes").params(param)
        
        disputes_array = []
        next_watermark = nil
          
        response["disputes"].keys.each do |key|
          # extract each of the customer's data from the response
          dispute_hash = response["disputes"][key]
          # store the watermark so we know where to start for the next page
          dispute_watermark = key
          # add the watermark to the dispute record
          dispute_hash["watermark"] = dispute_watermark
          if !next_watermark.present? || dispute_watermark>next_watermark
            next_watermark = dispute_watermark
          end
          
          # break out the invoice balance 
          if dispute_hash["invoice_balance"].present? && dispute_hash["invoice_balance"].size() > 0
            dispute_hash["invoice_balance_currency"] = dispute_hash["invoice_balance"].keys[0]
            dispute_hash["invoice_balance_amount"] = dispute_hash["invoice_balance"][dispute_hash["invoice_balance_currency"]]
          end
          
          # add the customer's data to the output for the trigger
          disputes_array << dispute_hash
        end
    
        {
          events: disputes_array,
          next_poll: (next_watermark || watermark),
          can_poll_more: disputes_array.length >= page_size
        }
      end,
    
      dedup: lambda do |event|
        event["watermark"]
      end,
    
      output_fields: lambda do |object_definitions|
        [
          { name: "closed_at", label: "Closed At" },
          { name: "opened_at", label: "Opened At" },
          { name: "opener", label: "Opener" },
          { name: "closer", label: "Closer" },
          { name: "opening_comment_text", label: "Opening Comment Text" },
          { name: "closing_comment_text", label: "Closing Comment Text" },
          { name: "invoice_number", label: "Invoice Number" },
          { name: "invoice_amount_paid", label: "Invoice Amount Paid" },
          { name: "invoice_balance_currency", label: "Invoice Balance Currency" },
          { name: "invoice_balance_amount", label: "Invoice Balance Amount (in cents)" },
          { name: "dispute_reason_identifier", label: "Dispute Reason Identifier" },
          { name: "dispute_reason_label_en", label: "Dispute Reason Label (English)" },
          { name: "dispute_reason_label_fr", label: "Dispute Reason Label (French)" },
          { name: "opening_comment_users_notified", label: "Opening Comment Users Notified" },
          { name: "closing_comment_user_notified", label: "Closing Comment User Notified" },
          { name: "creator_business_name", label: "Creator Business Name" },
          { name: "closer_business_name", label: "Closer Business Name" },
          { name: "invoice_identifier", label: "Invoice Identifier" },
          { name: "invoice_external_id", label: "Invoice External ID" },
          { name: "watermark", label: "Watermark" }
        ]
      end
    },
    payments_made_in_ARC: {
      description: "Payments Made in ARC",
    
      input_fields: lambda do
        [
          {
            name: "watermark",
            type: :string,
            optional: true,
            hint: "The starting point for retrieving payments made in ARC."
          }
        ]
      end,
    
      poll: lambda do |connection, input, watermark|
        page_size = 100
        
        param = {}
        if watermark.present?
          param = { watermark: watermark }
        elsif input["watermark"].present?
          param = { watermark: input["watermark"] }
        end
        
        response = get("#{connection['environment']}/api/exports/payment_amounts").params(param)
        
        payments_array = []
        next_watermark = nil
          
        response["payment_amounts"].keys.each do |key|
          # extract each of the customer's data from the response
          payment_hash = response["payment_amounts"][key]
          # store the watermark so we know where to start for the next page
          payment_watermark = key
          # add the watermark to the dispute record
          payment_hash["watermark"] = payment_watermark
          if !next_watermark.present? || payment_watermark>next_watermark
            next_watermark = payment_watermark
          end
          
          # add the customer's data to the output for the trigger
          payments_array << payment_hash
        end
    
        {
          events: payments_array,
          next_poll: (next_watermark || watermark),
          can_poll_more: payments_array.length >= page_size
        }
      end,
    
      dedup: lambda do |event|
        event["watermark"]
      end,
    
      output_fields: lambda do |object_definitions|
        [
          { name: "payment_reference", label: "Payment Reference" },
          { name: "checkout_token", label: "Checkout Token" },
          { name: "invoice_number", label: "Invoice Number" },
          { name: "date", label: "Date" },
          { name: "amount", label: "Amount" },
          { name: "plan_fee", label: "Plan Fee" },
          { name: "payment_amount", label: "Payment Amount" },
          { name: "payment_transaction_amount", label: "Payment Transaction Amount" },
          { name: "payment_transaction_token", label: "Payment Transaction Token" },
          { name: "payment_method", label: "Payment Method" },
          { name: "payment_from_bank_account", label: "Payment from Bank Account" },
          { name: "payment_from_credit_card", label: "Payment from Credit Card" },
          { name: "payment_institution_name", label: "Payment Institution Name" },
          { name: "payment_credit_card_brand", label: "Payment Credit Card Brand" },
          { name: "short_pay_indicator", label: "Short Pay Indicator" },
          { name: "payment_note", label: "Payment Note" },
          { name: "auto_debit_indicator", label: "Auto Debit Indicator" },
          { name: "invoice_balance", label: "Invoice Balance" },
          { name: "payment_timestamp", label: "Payment Timestamp" },
          { name: "invoice_division", label: "Invoice Division" },
          { name: "invoice_division_number", label: "Invoice Division Number" },
          { name: "invoice_division_name", label: "Invoice Division Name" },
          { name: "pay_to_bank_account", label: "Pay to Bank Account" },
          { name: "pay_to_bank_account_name", label: "Pay to Bank Account Name" },
          { name: "customer_identifier", label: "Customer Identifier" },
          { name: "customer_name", label: "Customer Name" },
          { name: "status", label: "Status" },
          { name: "status_reason", label: "Status Reason" },
          { name: "payment_source", label: "Payment Source" },
          { name: "payment_code", label: "Payment Code" },
          { name: "payment_description", label: "Payment Description" },
          { name: "gateway_authorization_code", label: "Gateway Authorization Code" },
          { name: "purchase_order_number", label: "Purchase Order Number" },
          { name: "ref1", label: "Ref1" },
          { name: "ref2", label: "Ref2" },
          { name: "ref3", label: "Ref3" },
          { name: "short_pay_reason_identifier", label: "Short Pay Reason Identifier" },
          { name: "short_pay_reason", label: "Short Pay Reason" },
          { name: "dispute_reason_identifier", label: "Dispute Reason Identifier" },
          { name: "dispute_reason", label: "Dispute Reason" },
          { name: "invoice_amount_paid", label: "Invoice Amount Paid" },
          { name: "invoice_identifier", label: "Invoice Identifier" },
          { name: "invoice_date", label: "Invoice Date" },
          { name: "invoice_external_id", label: "Invoice External ID" },
          { name: "invoice_currency", label: "Invoice Currency" },
          { name: "invoice_purchase_order_number", label: "Invoice Purchase Order Number" },
          { name: "invoice_ref1", label: "Invoice Ref1" },
          { name: "invoice_ref2", label: "Invoice Ref2" },
          { name: "invoice_ref3", label: "Invoice Ref3" },
          { name: "cumulative_customer_amount", label: "Cumulative Customer Amount" },
          { 
            name: "line_item_transactional_amounts", 
            label: "Line Item Transactional Amounts",
            type: "array",
            of: "object",
            properties: [
              { name: "line_item_number", label: "Line Item Number"},
              { name: "line_item_payment_amount", label: "Line Item Payment Amount"},
              { name: "line_item_balance", label: "Line Item Balance"},
              { name: "line_item_short_pay_indicator", label: "Line Item Short Pay Indicator"},
              { name: "line_item_payment_note", label: "Line Item Payment Note"},
              { name: "line_item_short_pay_reason_identifier", label: "Line Item Short Pay Reason Identifier"},
              { name: "line_item_short_pay_reason", label: "Line Item Short Pay Reason"},
              { name: "line_item_dispute_reason_identifier", label: "Line Item Dispute Reason Identifier"},
              { name: "line_item_dispute_reason", label: "Line Item Dispute Reason"}              
            ]
          },
          { name: "watermark", label: "Watermark" }
        ]
      end
    },
    view_updated_payments: {
      description: "View Updated Payments",
    
      input_fields: lambda do
        [
          {
            name: "watermark",
            type: :string,
            optional: true,
            hint: "The starting point for retrieving payments made in ARC."
          }
        ]
      end,
    
      poll: lambda do |connection, input, watermark|
        page_size = 100
        
        param = {}
        if watermark.present?
          param = { watermark: watermark }
        elsif input["watermark"].present?
          param = { watermark: input["watermark"] }
        end
        
        response = get("#{connection['environment']}/api/exports/payments/recent").params(param)
        
        payments_array = []
        next_watermark = nil
          
        response["payments"].keys.each do |key|
          # extract each of the customer's data from the response
          payment_hash = response["payments"][key]
          # store the watermark so we know where to start for the next page
          payment_watermark = key
          # add the watermark to the dispute record
          payment_hash["watermark"] = payment_watermark
          if !next_watermark.present? || payment_watermark>next_watermark
            next_watermark = payment_watermark
          end
          
          # add the customer's data to the output for the trigger
          payments_array << payment_hash
        end
    
        {
          events: payments_array,
          next_poll: (next_watermark || watermark),
          can_poll_more: payments_array.length >= page_size
        }
      end,
    
      dedup: lambda do |event|
        event["watermark"]
      end,
    
      output_fields: lambda do |object_definitions|
        [
          { name: "payment_reference", label: "Payment Reference" },
          { name: "date", label: "Date" },
          { name: "payment_amount", label: "Payment Amount" },
          { name: "payment_transaction_amount", label: "Payment Transaction Amount" },
          { name: "payment_method", label: "Payment Method" },
          { name: "auto_debit_indicator", label: "Auto Debit Indicator" },
          { name: "payment_timestamp", label: "Payment Timestamp" },
          { name: "customer_identifier", label: "Customer Identifier" },
          { name: "customer_name", label: "Customer Name" },
          { name: "status", label: "Status" },
          { name: "payment_source", label: "Payment Source" },
          { name: "payment_code", label: "Payment Code" },
          { name: "payment_description", label: "Payment Description" },
          { name: "gateway_authorization_code", label: "Gateway Authorization Code" },
          { name: "pay_to_bank_account", label: "Pay to Bank Account" },
          { name: "pay_to_bank_account_name", label: "Pay to Bank Account Name" },
          { name: "status_reason", label: "Status Reason" },
          { name: "signature", label: "Signature" },
          { 
            name: "payment_amounts", 
            label: "Payment Amounts",
            type: "array",
            of: "object",
            properties: [
              { name: "payment_reference", label: "Payment Reference"},
              { name: "checkout_token", label: "Checkout Token"},
              { name: "invoice_number", label: "Invoice Number"},
              { name: "date", label: "Date"},
              { name: "amount", label: "Amount"},
              { name: "plan_fee", label: "Plan Fee"},
              { name: "payment_amount", label: "Payment Amount"},
              { name: "payment_transaction_amount", label: "Payment Transaction Amount"},
              { name: "payment_transaction_token", label: "Payment Transaction Token"},
              { name: "payment_method", label: "Payment Method"},
              { name: "payment_from_bank_account", label: "Payment from Bank Account"},
              { name: "payment_from_credit_card", label: "Payment from Credit Card"},
              { name: "payment_institution_name", label: "Payment Institution Name"},
              { name: "payment_credit_card_brand", label: "Payment Credit Card Brand"},
              { name: "short_pay_indicator", label: "Short Pay Indicator"},
              { name: "payment_note", label: "Payment Note"},
              { name: "auto_debit_indicator", label: "Auto Debit Indicator"},
              { name: "invoice_balance", label: "Invoice Balance"},
              { name: "payment_timestamp", label: "Payment Timestamp"},
              { name: "invoice_division", label: "Invoice Division"},
              { name: "invoice_division_number", label: "Invoice Division Number"},
              { name: "invoice_division_name", label: "Invoice Division Name"},
              { name: "pay_to_bank_account", label: "Pay To Bank Account"},
              { name: "pay_to_bank_account_name", label: "Pay To Bank Account Name"},
              { name: "customer_identifier", label: "Customer Identifier"},
              { name: "customer_name", label: "Customer Name"},
              { name: "status", label: "Status"},
              { name: "status_reason", label: "Status Reason"},
              { name: "payment_source", label: "Payment Source"},
              { name: "payment_code", label: "Payment Code"},
              { name: "payment_description", label: "Payment Description"},
              { name: "gateway_authorization_code", label: "Gateway Authorization Code"},
              { name: "purchase_order_number", label: "Purchase Order Number"},
              { name: "ref1", label: "Ref1"},
              { name: "ref2", label: "Ref2"},
              { name: "ref3", label: "Ref3"},
              { name: "short_pay_reason_identifier", label: "Short Pay Reason Identifier"},
              { name: "short_pay_reason", label: "Short Pay Reason"},
              { name: "dispute_reason_identifier", label: "Dispute Reason Identifier"},
              { name: "dispute_reason", label: "Dispute Reason"},
              { name: "invoice_amount_paid", label: "Invoice Amount Paid"},
              { name: "invoice_identifier", label: "Invoice Identifier"},
              { name: "invoice_date", label: "Invoice Date"},
              { name: "invoice_external_id", label: "Invoice External ID"},
              { name: "invoice_currency", label: "Invoice Currency"},
              { name: "invoice_purchase_order_number", label: "Invoice Purchase Order Number"},
              { name: "invoice_ref1", label: "Invoice Ref1"},
              { name: "invoice_ref2", label: "Invoice Ref2"},
              { name: "invoice_ref3", label: "Invoice Ref3"},
              { name: "cumulative_customer_amount", label: "Cumulative Customer Amount"},
              { 
                name: "line_item_transactional_amounts", 
                label: "Line Item Transactional Amounts",
                type: "array",
                of: "object",
                properties: [
                  { name: "line_item_number", label: "Line Item Number"},
                  { name: "line_item_payment_amount", label: "Line Item Payment Amount"},
                  { name: "line_item_balance", label: "Line Item Balance"},
                  { name: "line_item_short_pay_indicator", label: "Line Item Short Pay Indicator"},
                  { name: "line_item_payment_note", label: "Line Item Payment Note"},
                  { name: "line_item_short_pay_reason_identifier", label: "Line Item Short Pay Reason Identifier"},
                  { name: "line_item_short_pay_reason", label: "Line Item Short Pay Reason"},
                  { name: "line_item_dispute_reason_identifier", label: "Line Item Dispute Reason Identifier"},
                  { name: "line_item_dispute_reason", label: "Line Item Dispute Reason"}              
                ]
              }
            ]
          },{ name: "watermark", label: "Watermark" }
        ]
      end
    }
  }
}