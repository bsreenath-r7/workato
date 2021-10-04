{
  title: "Workato CICD for Platform APIs",

  connection: {
    fields: [ 
      {
        name: "workato_environments",
        label: "Workato environments",
        item_label: "Environment",
        list_mode: "static",
        list_mode_toggle: false,
        type: "array",
        of: "object",
        properties: [
          {
            name: "name",
            label: "Environment name",
            optional: false,
            hint: "Workato environment identifier. For example, DEV, TEST, or PROD."
          },              
          {
            name: "email",
            label: "Email address",
            optional: false,
            hint: "Email address to access Workato platform APIs."
          },
          {
            name: "api_key",
            label: "API key",
            control_type: "password",
            optional: false,
            hint: "You can find your API key in the <a href=\"https://www.workato.com/users/current/edit#api_key\" target=\"_blank\">settings page</a>."
          }         
        ]
      }
    ],
    
    authorization: {
      type: "custom_auth",
    },
    
    base_uri: lambda do |connection|
      "https://www.workato.com"
    end,
       
  },
  
  test: lambda do |connection|
    connection["workato_environments"].each do |env|
      get("/api/users/me")
      .headers({ "x-user-email": "#{env["email"]}",
                 "x-user-token": "#{env["api_key"]}" })      
    end
  end,
  
  object_definitions: {
    environments_input: {
      fields: lambda do |connection, _|
        environments = connection["workato_environments"].map do |env|
          ["#{env["name"]}", "#{env["name"]}"]
        end
        
        [
          { 
            name: "workato_environment",
            label: "Workato environment",
            hint: "Select Workato environment.",
            optional: false,
            control_type: 'select',
            pick_list: environments
          }          
        ]
      end
    }, # environments_input.end
    
    package_details: {
      fields: lambda do
        [
          {
            name: "workato_environment",
            label: "Workato environment"
          },
          {
            name: "package_id",
            label: "Package ID"
          }, 
          {
            name: "content",
            label: "Package content"
          }           
        ]
      end
    }, # package_details.end    
  },
  
  actions: {
    export_download_package: {
      title: "Export and download package",
      subtitle: "Export and download package for manifest ID",
      
      help: "Use this action to build and export a manifest from the selected environment. This is an asynchronous request and uses Workato long action. Learn more <a href=\"https://docs.workato.com/workato-api/recipe-lifecycle-management.html#recipe-lifecycle-management\" target=\"_blank\">here</a>.",
      
      description: lambda do |input| 
        "Export <span class='provider'>package</span> from " \
        "Workato <span class='provider'>#{input["workato_environment"]}</span>"
      end,
      
      input_fields: lambda do |object_definitions| 
        object_definitions["environments_input"] +
        [
          {
            name: "manifest_id",
            label: "Manifest ID",
            hint: "Manifest ID to export.",
            optional: false
          }
        ]
      end,      
      
      execute: lambda do |connection, input, eis, eos, continue|
     
        continue = {} unless continue.present?
        current_step = continue['current_step'] || 1
        max_steps = 10
        step_time = current_step * 10 # This helps us wait longer and longer as we increase in steps
        headers = call("get_auth_headers", connection, "#{input["workato_environment"]}")
        
        if current_step == 1 # First invocation
          
          # https://docs.workato.com/workato-api/recipe-lifecycle-management.html#export-package-based-on-a-manifest
          response = post("/api/packages/export/#{input["manifest_id"]}")
          .headers(headers)
          .after_error_response(/.*/) do |_, body, _, message|
            error("#{message}: #{body}") 
          end
          
          # If job is in_progress, reinvoke after wait time
          if response["status"] == "in_progress"
              reinvoke_after(
                seconds: step_time, 
                continue: { 
                  current_step: current_step + 1, 
                  jobid: response['id']
                }
              )
          elsif response["status"] == "failed"
            error("#{response["error"]}")            
          elsif response["status"] == "completed"
            call("download_package", {
              "headers" => headers, 
              "workato_environment" => input["workato_environment"], 
              "package_id" => response["id"]
            })
          end # first_response_if.end
        
        # Subsequent invocations
        elsif current_step <= max_steps           
          
          # https://docs.workato.com/workato-api/recipe-lifecycle-management.html#get-package-by-id
          response = get("/api/packages/#{continue["jobid"]}")
          .headers(headers)
          .after_error_response(/.*/) do |_, body, _, message|
            error("#{message}: #{body}") 
          end
          
          if response["status"] == "in_progress"
              reinvoke_after(
                seconds: step_time, 
                continue: { 
                  current_step: current_step + 1, 
                  jobid: response['id']
                }
              )
          elsif response["status"] == "failed"
            error("#{response["error"]}")
          elsif response["status"] == "completed"
            call("download_package", {
              "headers" => headers, 
              "workato_environment" => input["workato_environment"], 
              "package_id" => response["id"]
            })
          end # subsequent_response_if.end

        else
          error("Job took too long!")
          
        end # outer.if.end
        
      end, # execute.end
      
      output_fields: lambda do |object_definitions|
        object_definitions["package_details"]
      end # output_fields.end
      
    }, # export_download_package.end
    
    download_package: {
      title: "Download package",
      subtitle: "Download existing package from Workato",
      
      help: "Use this action to download a package from the selected environment. Learn more <a href=\"https://docs.workato.com/workato-api/recipe-lifecycle-management.html#download-package\" target=\"_blank\">here</a>.",
      
      description: lambda do |input| 
        "Download <span class='provider'>package</span> from " \
        "Workato <span class='provider'>#{input["workato_environment"]}</span>"
      end,
      
      input_fields: lambda do |object_definitions| 
        object_definitions["environments_input"] +
        [
          {
            name: "package_id",
            label: "Pacakge ID",
            hint: "Package ID to export.",
            optional: false            
          }
        ]
      end, 
      
      execute: lambda do |connection, input, eis, eos, continue|
        
        headers = call("get_auth_headers", connection, "#{input["workato_environment"]}")
        call("download_package", {
          "headers" => headers, 
          "workato_environment" => input["workato_environment"], 
          "package_id" => input["package_id"]
        })        
    
      end, # execute.end
      
      output_fields: lambda do |object_definitions|
        object_definitions["package_details"]
      end # output_fields.end      
      
    }, # download_package.end
    
    import_package: {
      title: "Import package",
      subtitle: "Import package to Workato environment",
      
      help: "Use this action import a package to the selected environment. This is an asynchronous request and uses Workato long action. Learn more <a href=\"https://docs.workato.com/workato-api/recipe-lifecycle-management.html#import-package-into-a-folder\" target=\"_blank\">here</a>.",
      
      description: lambda do |input| 
        "Import <span class='provider'>package</span> to " \
        "Workato <span class='provider'>#{input["workato_environment"]}</span>"
      end,
      
      input_fields: lambda do |object_definitions| 
        object_definitions["environments_input"] +
        [
          {
            name: "content",
            label: "Pacakge content",
            hint: "Package content to import.",
            optional: false            
          },
          {
            name: "folder_id",
            label: "Folder ID",
            hint: "Folder ID to import package into.",
            optional: false
          },          
        ]
      end,
      
      execute: lambda do |connection, input, eis, eos, continue|
        
        continue = {} unless continue.present?
        current_step = continue['current_step'] || 1
        max_steps = 10
        step_time = current_step * 10 # This helps us wait longer and longer as we increase in steps
        headers = call("get_auth_headers", connection, "#{input["workato_environment"]}")        
        
        if current_step == 1 # First invocation

          # https://docs.workato.com/workato-api/recipe-lifecycle-management.html#export-package-based-on-a-manifest
          response = post("/api/packages/import/#{input["folder_id"]}?restart_recipes=true") 
          .headers(headers)
          .headers("Content-Type": "application/octet-stream")
          .request_body(input["content"])
          .after_error_response(/.*/) do |_, body, _, message|
            error("#{message}: #{body}") 
          end
          
          # If job is in_progress, reinvoke after wait time
          if response["status"] == "in_progress"
              reinvoke_after(
                seconds: step_time, 
                continue: { 
                  current_step: current_step + 1, 
                  jobid: response['id']
                }
              )
          elsif response["status"] == "failed"
            error("#{response["error"]}")            
          elsif response["status"] == "completed"
            {
              status: response["status"],
              job_id: response["id"]
            }
          end # first_response_if.end
          
        # Subsequent invocations
        elsif current_step <= max_steps           
          
          # https://docs.workato.com/workato-api/recipe-lifecycle-management.html#get-package-by-id
          response = get("/api/packages/#{continue["jobid"]}")
          .headers(headers)
          .after_error_response(/.*/) do |_, body, _, message|
            error("#{message}: #{body}") 
          end       
          
          if response["status"] == "in_progress"
              reinvoke_after(
                seconds: step_time, 
                continue: { 
                  current_step: current_step + 1, 
                  jobid: response['id']
                }
              )
          elsif response["status"] == "failed"
            error("#{response["error"]}")
          elsif response["status"] == "completed"
            {
              status: response["status"],
              job_id: response["id"]
            }
          end # subsequent_response_if.end

        else
          error("Job #{continue["jobid"]} took too long!")          
          
        end # outer.if.end
        
      end, # execute.end
      
      output_fields: lambda do |connection|
        [ 
          { name: "status" },
          { name: "job_id" },
        ]
      end
    }, # import_package.end
    
    list_folders: {
      title: "List folders",
      subtitle: "List folders in Workato workspace",
      
      help: "Use this action list folders in the selected environment. Supports up to 100 folders lookup in single action. Repeat this action in recipe for pagination if more than 100 folders lookup is needed.",
      
      description: lambda do |input| 
        "List <span class='provider'>folders</span> in " \
        "Workato <span class='provider'>#{input["workato_environment"]}</span>"
      end,
      
      input_fields: lambda do |object_definitions| 
        object_definitions["environments_input"] + 
        [
          {
            name: "page",
            hint: "Used for pagination.",
            type: "integer",
            default: 1
          }
        ]
      end, 
      
      execute: lambda do |connection, input, eis, eos, continue|
        
        headers = call("get_auth_headers", connection, "#{input["workato_environment"]}")
        { folders_list: get("/api/folders?page=#{input["page"]}&per_page=100")
        .headers(headers)
        .after_error_response(/.*/) do |_, body, _, message|
          error("#{message}: #{body}") 
        end }
        
      end, # execute.end
      
      output_fields: lambda do |object_definitions|
        [
          {
            name: "folders_list",
            label: "Folders list",
            control_type: "key_value",
            type: "array",
            of: "object",
            properties: [
              { name: "id" },
              { name: "name" },
              { name: "parent_id" },
              { name: "created_at" },
              { name: "updated_at" }            
            ]
          }
        ]
      end # output_fields.end      
      
    }, # download_package.end    
    
  },
  
  methods: {
    get_auth_headers: lambda do |connection, env|
      auth_obj = connection["workato_environments"].select { |e| e["name"].include?("#{env}") }
      {
        "x-user-email": "#{auth_obj[0]["email"]}",
        "x-user-token": "#{auth_obj[0]["api_key"]}"
      }
    end, # get_auth_headers.end
    
    download_package: lambda do |input|

      input["headers"][:Accept] = "*/*"
    
      # https://docs.workato.com/workato-api/recipe-lifecycle-management.html#download-package
      { 
        workato_environment: input["workato_environment"],
        package_id: input["package_id"],
        content: get("/api/packages/#{input["package_id"]}/download")
        .headers(input["headers"]).response_format_raw
        .after_error_response(/.*/) do |_code, body, _header, message|
          error("#{message}: #{body}")
        end
      }

    end, # download_package.end
    
  }
  
}