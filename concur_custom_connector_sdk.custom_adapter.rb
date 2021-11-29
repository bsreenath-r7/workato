{
  title: 'Concur - Custom Connector SDK',

  connection: {
    fields: [
      {
        name: 'username',
        optional: false,
        hint: 'Your Concur login username'
      },
      {
        name: 'password',
        optional: false,
        control_type: 'password',
        hint: 'Your Concur login password'
      },
      {
        name: 'consumerkey',
        optional: false,
        hint: 'Get your consumer key by registering partner application ' \
        "<a href='https://www.concursolutions.com/companyadmin/partnerapp/" \
        "registration.asp' target='_blank'>here</a>"
      },
      {
        name: 'environment',
        optional: false,
        control_type: 'select',
        pick_list: [
          ['Production', 'https://www.concursolutions.com'],
          ['Sandbox', 'https://implementation.concursolutions.com']
        ]
      }
    ],
    authorization: {
      type: 'custom_auth',
      acquire: lambda do |connection|
        encoded_cred = "#{connection['username']}:#{connection['password']}".
                       encode_base64
        response =
          get("#{connection['environment']}/net2/oauth2/accesstoken.ashx").
          headers(Authorization: "Basic #{encoded_cred}",
                  'X-ConsumerKey': connection['consumerkey'])
        {
          access_token: response['Access_Token']['Token']
        }
      end,
      refresh_on: [401, 403],
      apply: lambda do |connection|
        headers(Authorization: "OAuth #{connection['access_token']}")
      end
    },
    base_uri: lambda do |connection|
      connection['environment']
    end
  },

  methods: {
    generate_custom_fields: lambda do |config|
      size = 1
      custom_fields = []
      while size < (config['size'] + 1)
        field = { name: "#{config['type']}#{size}" }
=begin
# Original SDK code from workato that incorrectly generated customer fields for user objects
        field = { name: "#{config['type']}#{size}", type: 'object',
                  properties: [
                    { name: 'Type' },
                    { name: 'Value' },
                    { name: 'Code' },
                    { name: 'ListItemID' }
                  ] }
=end
        custom_fields << field
        size = size + 1
      end
      custom_fields
    end,
    parse_xml_to_hash: lambda do |xml_obj|
      xml_obj['xml']&.
        reject { |key, _value| key[/^@/] }&.
        inject({}) do |hash, (key, value)|
        if value.is_a?(Array)
          hash.merge(if (array_fields = xml_obj['array_fields'])&.include?(key)
                       {
                         key => value.map do |inner_hash|
                                  call('parse_xml_to_hash',
                                       'xml' => inner_hash,
                                       'array_fields' => array_fields)
                                end
                       }
                     else
                       {
                         key => call('parse_xml_to_hash',
                                     'xml' => value[0],
                                     'array_fields' => array_fields)
                       }
                     end)
        else
          value
        end
      end&.presence
    end,
    make_schema_builder_fields_sticky: lambda do |input|
      input.map do |field|
        if field[:properties].present?
          field[:properties] = call('make_schema_builder_fields_sticky',
                                    field[:properties])
        elsif field['properties'].present?
          field['properties'] = call('make_schema_builder_fields_sticky',
                                     field['properties'])
        end
        field[:sticky] = true
        field
      end
    end
  },
  object_definitions: {
    user: {
      fields: lambda do |_connection, _config_fields|
        [
          { name: 'LoginId' },
          { name: 'EmpId', label: 'Employee ID' },
          { name: 'LocaleName', hint: "The user's language locale code. " \
            'One of the Supported Locales. Example: United States English' \
            ' is en_US.' },
          { name: 'FirstName' },
          { name: 'LastName' },
          { name: 'Mi', label: 'Middle initial' },
          { name: 'EmailAddress' },
          { name: 'Active',
            hint: 'Whether the user is currently active. Format: Y/N.' },
          { name: 'LedgerName' },
          { name: 'LedgerKey' },
          { name: 'CtryCode', label: 'Country code',
            hint: "The user's two-digit country code." },
          { name: 'CrnKey',
            hint: "user's three character reimbursement currency" },
          { name: 'CtrySubCode', hint: 'The user’s two-digit country code and' \
            ' two-digit state or province code. Example: Washington State,' \
            ' United States is US-WA.' },
          { name: 'CashAdvanceAccountCode',
            abel: 'Account code for cash advances' },
          {
            name: 'ExpenseUser',
            hint: 'Whether the user has access to Expense.',
            type: 'boolean',
            control_type: 'checkbox',
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'ExpenseUser',
              type: 'string',
              control_type: 'text',
              toggle_hint: 'Use custom value',
              hint: 'Whether the user has access to Expense. Format: Y/N'
            }
          },
          {
            name: 'ExpenseApprover',
            hint: 'Whether the user is an Expense approver.',
            type: 'boolean',
            control_type: 'checkbox',
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'ExpenseApprover',
              type: 'string',
              control_type: 'text',
              toggle_hint: 'Use custom value',
              hint: 'Whether the user is an Expense approver. Format: Y/N'
            }
          },
          {
            name: 'TripUser',
            hint: 'Whether the user is an trip user.',
            type: 'boolean',
            control_type: 'checkbox',
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'TripUser',
              type: 'string',
              control_type: 'text',
              toggle_hint: 'Use custom value',
              hint: 'Whether the user is an trip user. Format: Y/N'
            }
          },
          {
            name: 'InvoiceUser',
            hint: 'Whether the user is an Expense approver.',
            type: 'boolean',
            control_type: 'checkbox',
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'InvoiceUser',
              type: 'string',
              control_type: 'text',
              toggle_hint: 'Use custom value',
              hint: 'Whether the user is an Expense approver. Format: Y/N'
            }
          },
          {
            name: 'InvoiceApprover',
            hint: 'Whether the user is an invoice approver.',
            type: 'boolean',
            control_type: 'checkbox',
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'InvoiceApprover',
              type: 'string',
              control_type: 'text',
              toggle_hint: 'Use custom value',
              hint: 'Whether the user is an invoice approver. Format: Y/N'
            }
          },
          { name: 'ExpenseApproverEmployeeID',
            label: 'Expense approver employee ID' },
          {
            name: 'IsTestEmp',
            hint: 'Whether the user is an test user.',
            type: 'boolean',
            control_type: 'checkbox',
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'IsTestEmp',
              type: 'string',
              control_type: 'text',
              toggle_hint: 'Use custom value',
              hint: 'Whether the user is an test user. Format: Y/N'
            }
          }
        ].concat(call('generate_custom_fields',
                      'type' => 'Custom',
                      'size' => 21)).
          concat(call('generate_custom_fields',
                      'type' => 'OrgUnit',
                      'size' => 6)).compact
      end
    },
    search_user: {
      fields: lambda do |_connection, _config_fields|
        [
          { name: 'Active', type: 'boolean' },
          { name: 'CellPhoneNumber' },
          { name: 'EmployeeID' },
          { name: 'FirstName' },
          { name: 'ID' },
          { name: 'LastName' },
          { name: 'LoginID' },
          { name: 'MiddleName' },
          { name: 'OrganizationUnit' },
          { name: 'PrimaryEmail' },
          { name: 'URI' }
        ]
      end

    },
    expense_report: {
      fields: lambda do |_connection, _config_fields|
        [
          { name: 'AmountDueCompanyCard', type: 'number' },
          { name: 'AmountDueEmployee', type: 'number' },
          { name: 'ApprovalStatusCode' },
          { name: 'ApprovalStatusName' },
          { name: 'ApproverLoginID' },
          { name: 'ApproverName' },
          { name: 'Country', label: 'Country code' },
          { name: 'CountrySubdivision' },
          { name: 'CreateDate', type: 'date_time' },
          { name: 'CurrencyCode' },
          { name: 'EverSentBack', type: 'boolean',
            control_type: 'checkbox' },
          { name: 'HasException' },
          { name: 'ID' },
          { name: 'LastComment' },
          { name: 'LastModifiedDate', type: 'date_time' },
          { name: 'LedgerName' },
          { name: 'Name', label: 'Report name' },
          { name: 'OwnerLoginID' },
          { name: 'OwnerName' },
          { name: 'PaidDate', type: 'date_time' },
          { name: 'PaymentStatusCode' },
          { name: 'PaymentStatusName' },
          { name: 'PersonalAmount', type: 'number' },
          { name: 'PolicyID' },
          { name: 'ProcessingPaymentDate', type: 'date_time' },
          { name: 'ReceiptsReceived' },
          { name: 'SubmitDate', type: 'date_time' },
          { name: 'Total', type: 'number' },
          { name: 'TotalApprovedAmount', type: 'number' },
          { name: 'TotalClaimedAmount', type: 'number' },
          { name: 'URI' },
          { name: 'UserDefinedDate', type: 'date_time' },
          { name: 'WorkflowActionUrl' }
        ].concat(call('generate_custom_fields',
                      'type' => 'Custom',
                      'size' => 20)).
          concat(call('generate_custom_fields',
                      'type' => 'OrgUnit',
                      'size' => 6)).compact
      end
    },

    custom_action_input: {
      fields: lambda do |_connection, config_fields|
        input_schema =
          parse_json(config_fields.dig('input', 'schema') || '[]')
        [
          {
            name: 'path',
            optional: false
          },
          (
            if %w[get delete].include?(config_fields['verb'])
              {
                name: 'input',
                type: 'object',
                control_type: 'form-schema-builder',
                sticky: input_schema.blank?,
                label: 'URL parameters',
                add_field_label: 'Add URL parameter',
                properties: [
                  {
                    name: 'schema',
                    extends_schema: true,
                    sticky: input_schema.blank?
                  },
                  (
                    if input_schema.present?
                      {
                        name: 'data',
                        type: 'object',
                        properties: call('make_schema_builder_fields_sticky',
                                         input_schema)
                      }
                    end
                  )
                ].compact
              }
            else
              {
                name: 'input',
                type: 'object',
                properties: [
                  {
                    name: 'schema',
                    extends_schema: true,
                    schema_neutral: true,
                    control_type: 'schema-designer',
                    sample_data_type: 'json_input',
                    sticky: input_schema.blank?,
                    label: 'Request body parameters',
                    add_field_label: 'Add request body parameter'
                  },
                  (
                    if input_schema.present?
                      {
                        name: 'data',
                        type: 'object',
                        properties: input_schema.
                          each { |field| field[:sticky] = true }
                      }
                    end
                  )
                ].compact
              }
            end
          ),
          {
            name: 'output',
            control_type: 'schema-designer',
            sample_data_type: 'json_http',
            extends_schema: true,
            schema_neutral: true,
            sticky: true
          }
        ]
      end
    },

    custom_action_output: {
      fields: lambda do |_connection, config_fields|
        parse_json(config_fields['output'] || '[]')
      end
    }
  },

  test: lambda do |_connection|
    get('/api/user/v1.0/user')
  end,

  actions: {

    custom_action: {
      description: "Custom <span class='provider'>action</span> " \
        "in <span class='provider'>Concur</span>",
      help: {
        body: 'Build your own Concur action with a HTTP request.',
        learn_more_url: 'https://developer.concur.com/api-reference/',
        learn_more_text: 'Concur API Documentation'
      },

      config_fields: [{
        name: 'verb',
        label: 'Request type',
        hint: 'Select HTTP method of the request',
        optional: false,
        control_type: 'select',
        pick_list: %w[get post put delete].map { |v| [v.upcase, v] }
      }],

      input_fields: lambda do |object_definitions|
        object_definitions['custom_action_input']
      end,

      execute: lambda do |_connection, input|
        verb = input['verb']
        if %w[get post put patch delete].exclude?(verb)
          error("#{verb} not supported")
        end
        data = input.dig('input', 'data').presence || {}

        case verb
        when 'get'
          #error ("#{input.dig('input', 'data')}")
          get(input['path'], data).
            after_error_response(/.*/) do |_code, body, _header, message|
              error("#{message}: #{body}")
            end
        when 'post'
          post(input['path'], data).
            after_error_response(/.*/) do |_code, body, _header, message|
              error("#{message}: #{body}")
            end
        when 'put'
          put(input['path'], data).
            after_error_response(/.*/) do |_code, body, _header, message|
              error("#{message}: #{body}")
            end
        when 'delete'
          delete(input['path'], data).
            after_error_response(/.*/) do |_code, body, _header, message|
              error("#{message}: #{body}")
            end
        end
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['custom_action_output']
      end
    },

    search_users: {
      description: 'Search <span class="provider">users</span> '\
        ' in <span class="provider">Concur</span>',
      help: {
        body: 'Search users action uses the' \
          " <a href='https://developer.concur.com/api-explorer/v3-0/" \
          "Users.html'>Get all users API</a>.",
        learn_more_url: 'https://developer.concur.com/api-explorer/' \
        'v3-0/Users.html',
        learn_more_text: 'Get all users API'
      },
      input_fields: lambda do
        [
          {
            name: 'user',
            label: 'Login ID',
            hint: 'Login ID of Concur User. Usually the email address',
            optional: true
          },
          {
            name: 'employeeID',
            label: 'Employee ID',
            optional: true
          },
          {
            name: 'primaryEmail',
            label: 'Primary email',
            optional: true
          },
          {
            name: 'lastName'
          },
          { name: 'active', type: 'boolean',
            control_type: 'checkbox',
            toggle_hint: 'Select from options',
            toggle_field: {
              name: 'active',
              label: 'Active',
              type: 'string',
              control_type: 'text',
              render_input: 'boolean_conversion',
              parse_output: 'boolean_conversion',
              hint: 'Indicates whether to return active or inactive users',
              toggle_hint: 'Use custom value'
            } },
          { name: 'limit', hint: 'The number of records to return.' \
            ' Default value: 25. Maximum: 100.' },
          { name: 'offset', hint: 'The starting point of the next set of ' \
            'results, after the limit specified in the limit field has ' \
            'been reached.' }
        ]
      end,
      execute: lambda do |_connection, input|
        response = get('/api/v3.0/common/users').params(input)
        { users: response['Items'],
          next_page: response['NextPage'] }
      end,
      output_fields: lambda do |object_definitions|
        [
          { name: 'users', type: 'array', of: 'object',
            properties: object_definitions['search_user'] },
          { name: 'next_page' }
        ]
      end
    },

    get_user_by_login_id: {
      description: 'Get <span class="provider">user</span> details by '\
        ' login ID in <span class="provider">Concur</span>',
      help: {
        body: 'Get user details action uses the Retrieve a ' \
        "User's Information API",
        learn_more_url: 'https://developer.concur.com/api-reference/user/' \
        'index.html#getUser',
        learn_more_text: 'Retrieve a User’s Information'
      },
      input_fields: lambda do |_object_definitions|
        [
          { name: 'loginID', optional: false }
        ]
      end,
      execute: lambda do |_connection, input|
        get('api/user/v1.0/user', input)
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['user']
      end
    },

    process_workflow_request: {
      description: 'Process <span class="provider">workflow</span> request '\
        ' in <span class="provider">Concur</span>',
      help: {
        body: 'Process workflow request action uses the' \
          " <a href='https://developer.concur.com/api-explorer/v3-0/" \
          "Users.html'>Workflow actions API</a>.",
        learn_more_url: 'https://developer.concur.com/api-reference/expense/' \
        'expense-report/post-report-workflow-action.html#workflow-actions',
        learn_more_text: 'Workflow actions API'
      },
      input_fields: lambda do |_object_definitions|
        [
          {
            name: 'workflow_step_id',
            optional: false
          },
          {
            name: 'Action', optional: false,
            label: 'Workflow Action',
            control_type: 'select',
            pick_list: 'workflow_actions',
            toggle_hint: 'Select from options list',
            toggle_field: {
              name: 'Action',
              label: 'Workflow Action',
              type: 'string',
              control_type: 'text',
              toggle_hint: 'Use custom value',
              hint: 'Allowed values are: <b>Approve, Send Back to Employee,' \
              ' or Recall to Employee</b>'
            }
          },
          {
            name: 'Comment',
            hint: 'Must be used with the Send Back to Employee workflow' \
            ' action. Max length: 2000'
          }
        ]
      end,
      execute: lambda do |_connection, input|
        if input['Action'] == 'Send Back to Employee' &&
           input['Comment'].present? == false
          error('Comment is required when workflow action is Send Back' \
            ' to Employee')
        end
        response = post('/api/expense/expensereport/v1.1/report/' \
          "#{input['workflow_step_id']}/workflowaction").
                   headers('Content-Type': 'application/xml').
                   payload("Action": [{ "content!": input['Action'] }],
                           "Comment": [{ "content!": input['Comment'] }]).
                   format_xml('WorkflowAction',
                              '@xmlns' => 'http://www.concursolutions.com/' \
                              'api/expense/expensereport/2011/03',
                              strip_response_namespaces: true).
                   after_error_response(/.*/) do |_code, body, _header, message|
                     error("#{message}: #{body}")
                   end
        call('parse_xml_to_hash',
             'xml' => response,
             'array_fields' => []) || {}
      end,
      output_fields: lambda do |_object_definitions|
        
      end
    },
    update_user: {
      description: "Update <span class='provider'>user</span> in <span class='provider'>Concur</span>",
      title: 'Update user in Concur',
      input_fields: lambda do |object_definitions|
        [
          { name: "LoginId", optional: false },
          { name: "EmployeeId", optional: false },
          { name: "FirstName", optional: false },
          { name: "LastName", optional: false },
          { name: "EmailAddress", optional: false },
          { name: "LocaleName", optional: false },
          { name: "CountryCode", optional: false },
          { name: "LedgerCode", optional: false, hint: "For Ledger Name 'NetSuite Financials', user Ledger Code 'NS'" },
          { name: "CurrencyKey", optional: false },
          { name: "Active", label: "Active", optional: false, control_type: "select", pick_list: "boolean_values", toggle_hint: "Select",
            toggle_field: {
              name: "Active",
              label: "Active",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Custom",
              hint: "Y or N"
            }
          },
          { name: "Custom21", label: "Custom21 Code", optional: false },
          { name: "OrgUnit1", label: "OrgUnit1 Code", optional: false },
          { name: "OrgUnit2", label: "OrgUnit2 Code", optional: false },
          { name: "OrgUnit3", label: "OrgUnit3 Code", optional: false },
          { name: "OrgUnit4", label: "OrgUnit4 Code", optional: false }
        ]
      end,
      execute: lambda do |_connection, input|
        response = post("api/user/v1.0/users").
                   headers('Content-Type': 'application/xml').
                   payload("UserProfile": {
                     	"FeedRecordNumber": 1,
                     	"LoginId": input["LoginId"],
                     	"EmpId": input["EmployeeId"], 
                     	"Password": "",
                     	"FirstName": input["FirstName"],
                     	"LastName": input["LastName"],
                     	"EmailAddress": input["EmailAddress"],
                     	"LocaleName": input["LocaleName"],
                     	"CtryCode": input["CountryCode"],
                     	"LedgerKey": input["LedgerCode"],
                     	"CrnKey": input["CurrencyKey"],
                     	"Active": input["Active"],
                     	"Custom21": input["Custom21"],
                     	"OrgUnit1": input["OrgUnit1"],
                     	"OrgUnit2": input["OrgUnit2"],
                     	"OrgUnit3": input["OrgUnit3"],
                     	"OrgUnit4": input["OrgUnit4"]
                     }).
                   format_xml('batch',
                              '@xmlns' => 'http://www.concursolutions.com/api/user/2011/02',
                              strip_response_namespaces: true).
                   after_error_response(/.*/) do |_code, body, _header, message|
                     error("#{message}: #{body}")
                   end
        call('parse_xml_to_hash',
             'xml' => response,
             'array_fields' => []) || {}
      end,
      output_fields: lambda do |_|
        [
          {
            name: 'user-batch-result', type: 'object', properties: [
              { name: 'records-succeeded' },
              { name: 'records-failed' },
              { 
                name: 'errors', type: "array", of: "object", properties: [
                  { name: 'EmployeeID' },
                  { name: 'FeedRecordNumber' },
                  { name: 'message' }
                ]
              },
              { 
                name: 'UsersDetails', type: "array", of: "object", properties: [
                  { name: 'EmployeeID' },
                  { name: 'FeedRecordNumber' },
                  { name: 'Status' }
                ]
              }              
            ]
          }
        ]
      end
    }
  },

  triggers: {
    new_updated_expenses: {
      input_fields: lambda do |_object_definitions|
        [
          {
            name: 'approvalStatusCode', label: 'Approval Status',
            sticky: true,
            control_type: 'select', pick_list: 'approval_status_list',
            toggle_hint: 'Use from Options list',
            toggle_field: {
              name: 'approvalStatusCode',
              label: 'Approve status code',
              type: 'string',
              control_type: 'text',
              toggle_hint: 'Use custom value',
              hint: 'Allowed values are: A_AAFH, A_ACCO, A_APPR, A_EXTV, ' \
              'A_FILE, A_NOTF, A_PBDG, A_PECO, A_PEND, A_PVAL, A_RESU, ' \
              'A_RHLD, A_TEXP. For custom codes, contact Concur Developer' \
              ' Support.'
            }
          },
          {
            name: 'paymentStatusCode', label: 'Payment Status',
            sticky: true,
            control_type: 'select', pick_list: 'approval_status_list',
            toggle_hint: 'Use from Options list',
            toggle_field: {
              name: 'paymentStatus',
              label: 'Invoice sayment Status',
              type: 'string',
              control_type: 'text',
              toggle_hint: 'Use custom value',
              hint: 'Allowed values are: P_HOLD, P_NOTP, P_PAID, P_PAYC, ' \
              'P_PROC. For custom codes, contact Concur Developer Support.'
            }
          },
          {
            name: 'since',
            label: 'When first started, this recipe should pick up events from',
            hint: 'When you start recipe for the first time, ' \
              'it picks up trigger events from this specified date and time. ' \
              'Leave empty to get records created or updated one hour ago',
            sticky: true,
            type: 'timestamp'
          }
        ]
      end,
      poll: lambda do |_connection, input, closure|
        last_updated_at = closure&.[]('last_updated_at') ||
                          (input.delete('since') || 1.day.ago).to_time.
                          utc.strftime('%Y-%m-%dT%H:%M:%S')
        limit = 5
        response = if (next_page = closure&.[]('next_page')).present?
                     get(next_page)
                   else
                     get('/api/v3.0/expense/reports', input).
                       params(user: 'ALL', limit: limit,
                              submitDateAfter: last_updated_at)
                   end
        reports = response['Items']&.sort_by { |rep| rep['LastModifiedDate'] }
        closure = {
          'last_updated_at' => reports&.last&.[]('LastModifiedDate') ||
                               now.to_time.utc.strftime('%Y-%m-%dT%H:%M:%S'),
          'next_page' => response['NextPage']
        }
        {
          events: reports,
          next_poll: closure,
          can_poll_more: response['NextPage'].present?
        }
      end,
      dedup: lambda do |report|
        "#{report['ID']}_#{report['LastModifiedDate']}"
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['expense_report']
      end
    }
  },

  pick_lists: {
    approval_status_list: lambda do
      [
        ['Report submission triggered an anomaly and fraud check', 'A_AAFH'],
        ['Report is pending reviews', 'A_ACCO'],
        ['Report has been approved', 'A_APPR'],
        ['Report is pending external validation', 'A_APPR'],
        ['Report has been submitted', 'A_FILE'],
        ['Report has not been submitted', 'A_NOTF'],
        ['Report approval is pending Budget approval', 'A_PBDG'],
        ['Report approval is pending Cost object approval', 'A_PECO'],
        ['Report is pending manager approval', 'A_PEND'],
        ['Report is pending prepayment validation', 'A_PVAL'],
        ['Report needs to be resubmitted', 'A_RESU'],
        ['Report submission is pending receipt images', 'A_RHLD'],
        ['Report expired in approval queue', 'A_TEXP']
      ]
    end,
    payment_status_list: lambda do |_connection|
      [
        ['Report payment is on hold', 'P_HOLD'],
        ['Report has not been paid', 'P_NOTP'],
        ['Report has been paid', 'P_PAID'],
        ['Payment is confirmed', 'P_PAYC'],
        ['Report is in process to be paid', 'P_PROC']
      ]
    end,
    workflow_actions: lambda do |_connection|
      [
        %w[Approve Approve],
        ['Send Back to Employee', 'Send Back to Employee'],
        ['Recall to Employee', 'Recall to Employee']
      ]
    end,
    boolean_values: lambda do |_connection|
    [
      ['Yes', 'Y'],
      ['No', 'N']
    ]
  end
  }
}
