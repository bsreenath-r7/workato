{
  title: 'Guru',

  connection: {
    fields: [
      {
        name: 'username',
        optional: false,
        hint: 'Your Guru account username'
      },
      {
        name: 'api_token',
        label: 'API Token',
        optional: false,
        control_type: 'password',
        hint: 'You can generate your API token by following this article ' \
        '<a href=\"https://developer.getguru.com/docs/user-tokens-vs-collection-tokens\" target=\"_blank\">here</a>'
      }
    ],

    authorization: {
      type: 'basic_auth',

      credentials: -> (connection) {
        user(connection['username'])
        password(connection['api_token'])
        headers("X-Guru-Application": "workato")
        headers("X-Amzn-Trace-Id": "GApp=workato")
      }
    },

    base_uri: -> (_connection) {
      'https://api.getguru.com/api/v1/'
    }
  },

  test: -> (_connection) {
    get('whoami')
  },

  methods: {
    create_webhook: -> (webhook_url, filter) {
      post("webhooks")
        .payload(
          targetUrl: webhook_url,
          deliveryMode: 'BATCH',
          status: 'ENABLED',
          filter: filter)
    },

    default_card_sample_output: -> (event_type_name) {
      {
        :results => [
          {
            :properties => {
              :cardId => 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
              :source => 'UI',
              :collectionId => 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
            },
            :id => 'cccccccc-cccc-cccc-cccc-cccccccccccc',
            :eventType => event_type_name,
            :user => 'user@getguru.com',
            :eventDate => '2021-05-17T16:50:40.391+0000'
          }
        ]
      }
    },

    delete_webhook: -> (webhook_id) {
      delete("webhooks/#{webhook_id}")
    },

    format_board: -> (board) {
      unless board.nil?
        board.except('slug', 'collection').merge(
          {
            'boardUrl': call('format_board_url', board['slug']),
            'collection': call('format_collection', board['collection'])
          }
        )
      end
    },

    format_board_url: -> (slug) {
      "https://app.getguru.com/boards/#{slug}"
    },

    format_card: -> (card) {
      unless card.nil?
        card.except('collection', 'slug', 'boards').merge(
          {
            'cardUrl' => call('format_card_url', card['slug']),
            'collection' => call('format_collection', card['collection']),
            'boards' => card['boards']&.map { |board| call('format_board', board) }
          }
        )
      end
    },

    format_card_url: -> (slug) {
      "https://app.getguru.com/card/#{slug}"
    },

    format_collection: -> (collection) {
      unless collection.nil?
        {
          'id' => collection['id'],
          'name' => collection['name'],
          'description' => collection['description'],
          'boards' => collection['boards'],
          'slug' => call('format_collection_url', collection['slug']),
          'color' => collection['color'],
          'stats' => call('format_stats', collection.dig('collectionStats', 'stats')),
          'publicCardsEnabled' => collection['publicCardsEnabled'],
          'cards' => collection['cards'],
          'assistEnabled' => collection['assistEnabled'],
          'publicCards' => collection['publicCards']
        }
      end
    },

    format_collection_url: -> (slug) {
      "https://app.getguru.com/collections/#{slug}"
    },

    format_stats: -> (stats) {
      unless stats.nil?
        trust_score_record = stats.dig('team-trust-score').present? ? stats.dig('team-trust-score') : stats.dig('collection-trust-score')
        card_count_record = stats.dig('team-card-count').present? ? stats.dig('team-card-count') : stats.dig('card-count')

        verified = trust_score_record.fetch('trustedCount', 0)
        unverified = trust_score_record.fetch('needsVerificationCount', 0)
        total_cards = card_count_record.fetch('count', 0)
        trust_score = total_cards == 0 ? 100 : ((100 * verified) / total_cards)

        {
          'needsVerificationCount' => unverified,
          'trustedCount' => verified,
          'cardCount' => total_cards,
          'trustScore' => trust_score
        }
      end
    },

    search_query_pagination_response: -> (headers, body) {
      {
        cards: (body.presence || []).map { |card| call('format_card', card) },
        next_page: headers['link'].present? ? headers['link'].split(';').first[1..-2] : nil
      }
    }
  },

  object_definitions: {
    board: {
      fields: -> {
        [
          { name: "id", label: "Board ID" },
          { name: "title", label: "Board Name" },
          { name: "description", label: "Description" },
          { name: "boardUrl", label: "Board URL" },
          {
            name: 'collection', label: 'Collection', type: 'object', properties:
            [
              { name: "id", label: "Collection ID", hint: "ID of the containing collection" },
              { name: "name", label: "Collection Name", hint: "Name of the containing collection" },
            ]
          }
        ]
      }
    },

    card: {
      fields: -> {
        user_properties = [
          { name: 'status', label: 'Status' },
          { name: 'email', label: 'Email' },
          { name: 'firstName', label: 'First Name' },
          { name: 'lastName', label: 'Last Name' },
          { name: 'profilePicUrl', label: 'Profile Pic URL' }
        ]

        collection_properties = [
          { name: 'id', label: 'Collection ID', hint: 'ID of the containing collection' },
          { name: 'name', label: 'Collection Name', hint: 'Name of the containing collection' },
          { name: 'slug', label: 'Collection URL' },
          { name: 'color', label: 'Collection Color' }
        ]

        board_properties = [
          { name: "id", label: "Board ID" },
          { name: "title", label: "Board Name" },
          { name: "description", label: "Description" },
          { name: "boardUrl", label: "Board URL" }
        ]

        tag_properties = [
          { name: "id", label: "Tag ID" },
          { name: "value", label: "Tag Value" },
          { name: "categoryId", label: "Tag Category ID" },
          { name: "categoryName", label: "Tag Category Name" },
          { name: "numberOfCards", label: "Number of Cards Tagged" }
        ]

        [
          { name: 'id', label: 'ID' },
          { name: 'preferredPhrase', label: 'Card Title' },
          { name: 'content', label: 'Card content, in HTML' },
          { name: 'cardUrl', label: 'Card URL' },
          { name: 'collection', label: 'Collection', type: 'object', properties: collection_properties },
          { name: 'originalOwner', label: 'Original Owner', type: 'object', properties: user_properties },
          { name: 'dateCreated', label: 'Date Created', type: 'date' },
          { name: 'lastVerified', label: 'Date Last Verified', type: 'date' },
          { name: 'lastVerifiedBy', label: 'Last Verified By', type: 'object', properties: user_properties },
          { name: 'lastModified', label: 'Date Last Modified', type: 'date' },
          { name: 'lastModifiedBy', label: 'Last Modified By', type: 'object', properties: user_properties },
          { name: 'verificationState', label: 'Verification State' },
          { name: 'verificationType', label: 'Verification Type' },
          { name: 'verificationInitiationDate', label: 'Verification Initiation Date', type: 'date' },
          { name: 'verificationInitiator', label: 'Verification Initiator', type: 'object', properties: user_properties },
          { name: 'verificationReasons', label: 'Verification Reasons', type: 'array' },
          { name: 'nextVerificationDate', label: 'Next Verification Date' },
          { name: 'verificationInterval', label: 'Verification Interval' },
          { name: 'knowledgeAlerts', label: 'Knowledge Alerts' },
          { name: 'hasDrafts', label: 'Has Drafts' },
          { name: 'publicLinkAllowed', label: 'Public Link Allowed' },
          { name: 'commentCount', label: 'Comment Count' },
          { name: 'boards', label: 'Boards', type: 'array', of: 'object', properties: board_properties },
          { name: 'tags', label: 'Tags', type: 'array', of: 'object', properties: tag_properties }
        ]
      }
    },

    card_id_input: {
      fields: -> {
        [
          { name: 'cardId', label: 'Card ID', optional: false }
        ]
      }
    },

    collection: {
      fields: -> {
        [
          { name: 'id', label: 'Collection Id' },
          { name: 'name', label: 'Collection name' },
          { name: 'description', label: "Collection Description" },
          { name: 'boards', type: 'integer', label: 'Number of boards' },
          { name: 'slug', label: 'Collection URL' },
          { name: 'color', label: 'Collection Color' },
          { name: 'stats', label: 'Collection Stats', type: 'object', properties:
            [
              { name: 'needsVerificationCount', label: 'Needs Verification Count', type: 'integer' },
              { name: 'trustedCount', label: 'Trusted Count', type: 'integer' },
              { name: 'cardCount', label: 'Card Count', type: 'integer' },
              { name: 'trustScore', label: 'Trust Score', type: 'integer' }
            ]
          },
          { name: 'publicCardsEnabled', type: 'boolean', label: 'Public Cards Enabled' },
          { name: 'cards', type: 'integer', label: 'Number of Cards' },
          { name: 'assistEnabled', type: 'boolean', label: 'Assist Enabled' },
          { name: 'publicCards', type: 'integer', label: 'Number of Public Cards' }
        ]
      }
    },

    collection_trust_score: {
      fields: -> {
        [
          { name: 'id', label: 'Collection ID' },
          { name: 'collectionName', label: 'Collection Name' },
          { name: 'collectionUrl', label: 'Collection URL' },
          { name: 'direction', label: 'Above or Below threshold' },
          { name: 'threshold', label: 'Threshold for Score' },
          { name: 'trustScore', label: 'Collection Trust Score' },
          { name: 'verifiedCards', label: 'Number of Verified Cards' },
          { name: 'unverifiedCards', label: 'Number of Unverified Cards' },
          { name: 'totalCards', label: 'Total number of cards' },
          { name: 'cardsToGoal', label: 'Cards to Goal' },
          { name: 'topVerifier1', label: 'Top Verifier 1' },
          { name: 'topVerifierCards1', label: 'Top Verifier 1 Cards' },
          { name: 'topVerifier2', label: 'Top Verifier 2' },
          { name: 'topVerifierCards2', label: 'Top Verifier 2 Cards' },
          { name: 'topVerifier3', label: 'Top Verifier 3' },
          { name: 'topVerifierCards3', label: 'Top Verifier 3 Cards' },
        ]
      }
    },

    create_card_input: {
      fields: -> {
        [
          { name: 'preferredPhrase', label: 'Card title', optional: false },
          {
            name: 'content',
            label: 'Card content',
            hint: 'Accepts HTML or Markdown',
            optional: false,
            control_type: 'text-area'
          },
          {
            name: 'collectionId',
            label: 'Collection',
            control_type: 'select',
            pick_list: 'collections_user_can_author',
            optional: false,
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'collectionId',
              label: 'Collection ID',
              type: 'string',
              control_type: 'text',
              optional: false,
              toggle_hint: 'Enter Collection ID'
            }
          },
          { name: 'boardId',
            label: 'Board',
            control_type: 'select',
            pick_list: 'boards_in_collection',
            pick_list_params: { collectionId: 'collectionId' },
            hint: 'To filter by board, a collection must be selected first.',
            optional: true,
            sticky: true,
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'boardId',
              label: 'Board ID',
              type: 'string',
              control_type: 'text',
              optional: true,
              toggle_hint: 'Enter Board ID'
            }
          },
          {
            name: 'tagIds',
            label: 'Tag ID',
            optional: true,
            sticky: true,
            type: 'string',
            hint: "Select tags you would like to apply to new card",
            control_type: 'multiselect',
            pick_list: 'tags',
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'tagIds',
              label: 'Tag ID',
              hint: 'Comma separated list of tag IDs',
              optional: true,
              type: 'array',
              of: 'string',
              control_type: 'text',
              toggle_hint: 'Enter Tag IDs'
            }
          },
          {
            name: 'verifier',
            label: 'Verifier',
            control_type: 'select',
            pick_list: 'verifiers',
            pick_list_params: { collection_id: 'collectionId' },
            optional: false
          },
          {
            name: 'verificationInterval',
            label: 'Verification Interval',
            hint: 'Interval for which Card will become unverified',
            control_type: 'select',
            pick_list: 'verification_intervals',
            optional: false
          },
          {
            name: 'shareStatus',
            control_type: 'select',
            pick_list: 'share_status',
            sticky: true,
            default: 'TEAM',
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'shareStatus',
              label: 'Share status',
              type: 'string',
              control_type: 'text',
              optional: true,
              toggle_hint: 'Enter custom value',
              hint: 'Allowed values are: TEAM, PRIVATE, PUBLIC',
              default: 'TEAM'
            }
          }
        ]
      }
    },

    default_card_trigger_output: {
      fields: -> {
        [
          { name: 'results', type: 'array', of: 'object', properties:
            [
              { name: 'id' },
              { name: 'eventType' },
              { name: 'eventDate' },
              { name: 'user' },
              { name: 'properties', type: 'object', properties:
                [
                  { name: 'cardId' },
                  { name: 'source' },
                  { name: 'collectionId' },
                ]
              }
            ]
          }
        ]
      }
    },

    empty: {
      fields: -> {
        []
      }
    },

    group: {
      fields: -> {
        [
          { name: 'id', label: 'Group ID' },
          { name: 'name', label: 'Group Name' },
          { name: 'numberOfMembers', type: 'integer', label: 'Number of Members' },
          { name: 'dateCreated', type: 'date_time', control_type: 'date_time', label: 'Date Created' },
          { name: 'groupIdentifier', label: 'Group Identifier' },
          { name: 'numberOfCardsAsVerifier', type: 'integer', label: 'Number of Cards as Verifier' },
          { name: 'modifiable', type: 'boolean', label: 'Modifiable' },
          { name: 'userModifiable', label: 'User Modifiable' }
        ]
      }
    },

    member: {
      fields: -> {
        [
          { name: 'id', label: 'User ID' },
          { name: 'status', label: 'User Status' },
          { name: 'email' },
          { name: 'firstName' },
          { name: 'lastName' },
          { name: 'dateCreated', type: 'date_time', control_type: 'date_time' },
          { name: 'profilePicUrl', label: 'Profile picture URL', control_type: 'url' }
        ]
      }
    },

    optional_collection_board_dropdown: {
      fields: -> {
        [
          { name: 'collectionId',
            label: 'Collection',
            control_type: 'select',
            pick_list: 'collections_user_has_access',
            optional: true,
            sticky: true,
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'collectionId',
              label: 'Collection ID',
              type: 'string',
              control_type: 'text',
              optional: true,
              toggle_hint: 'Enter Collection ID'
            }
          },
          { name: 'boardId',
            label: 'Board',
            control_type: 'select',
            pick_list: 'boards_in_collection',
            pick_list_params: { collectionId: 'collectionId' },
            hint: 'To filter by board, a collection must be selected first.',
            optional: true,
            sticky: true,
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'boardId',
              label: 'Board ID',
              type: 'string',
              control_type: 'text',
              optional: true,
              toggle_hint: 'Enter Board ID'
            }
          }
        ]
      }
    },

    search_cards_input: {
      fields: -> {
        [
          {
            name: 'q',
            label: 'Query',
            hint: 'Filter cards using <a href="https://developer.getguru.com/docs/guru-query-language" target="_blank">Guru Query Language</a>',
            optional: true,
            sticky: true,
            type: 'string',
            control_type: 'text-area'
          },
          {
            name: 'token',
            label: 'Pagination Token',
            type: 'string',
            hint: 'Use <b>Link</b> from previous output to navigate.',
            optional: true,
            sticky: true
          },
          { name: 'showArchived', type: 'boolean',
            control_type: 'checkbox',
            render_input: 'boolean_conversion',
            parse_output: 'boolean_conversion',
            optional: true,
            sticky: true,
            toggle_hint: 'Select from list',
            toggle_field: {
              toggle_hint: 'Enter custom value',
              hint: 'Allowed values are: true or false.',
              name: 'showArchived', type: 'boolean',
              control_type: 'text',
              render_input: 'boolean_conversion',
              parse_output: 'boolean_conversion',
              label: 'Show archived',
              optional: true
            } },
          { name: 'maxResults', label: 'Limit', hint: 'Page size. Maximum value of 50.',
            type: 'integer', control_type: 'integer', optional: true, sticky: true },
          { name: 'queryType', control_type: 'select',
            sticky: true,
            pick_list: 'query_types',
            optional: true,
            toggle_hint: 'Select from list',
            toggle_field: {
              toggle_hint: 'Enter custom value',
              name: 'queryType', type: 'string',
              control_type: 'text',
              label: 'Query type',
              optional: true,
              hint: 'Allowed values are: cards, questions, archived, recovered, and legacy.'
            } },
          { name: 'sortField', control_type: 'select',
            sticky: true,
            pick_list: 'sort_fields',
            optional: true,
            toggle_hint: 'Select from list',
            toggle_field: {
              toggle_hint: 'Enter custom value',
              name: 'sortField', type: 'string',
              control_type: 'text',
              label: 'Sort field',
              optional: true,
              hint: 'Allowed values are: lastModified, dateCreated, lastVerified, and nextVerificationDate.'
            } },
          { name: 'sortOrder', control_type: 'select',
            sticky: true,
            pick_list: [
              %w[Ascending asc],
              %w[Descending desc]
            ],
            optional: true,
            toggle_hint: 'Select from list',
            toggle_field: {
              toggle_hint: 'Enter custom value',
              name: 'sortOrder', type: 'string',
              control_type: 'text',
              label: 'Sort order',
              optional: true,
              hint: 'Allowed values are: asc or desc.'
            } }
        ]
      }
    },

    stats: {
      fields: -> {
        [
          { name: 'needsVerificationCount', label: 'Needs Verification Count', type: 'integer' },
          { name: 'trustedCount', label: 'Trusted Count', type: 'integer' },
          { name: 'cardCount', label: 'Card Count', type: 'integer' },
          { name: 'trustScore', label: 'Trust Score', type: 'integer' }
        ]
      }
    },

    tag: {
      fields: -> {
        [
          { name: "id", label: "Tag ID" },
          { name: "value", label: "Tag Value" },
          { name: "categoryId", label: "Tag Category ID" },
          { name: "categoryName", label: "Tag Category Name" },
          { name: "numberOfCards", label: "Number of Cards Tagged" }
        ]
      }
    },

    tag_category: {
      fields: -> {
        [
          { name: 'name' },
          { name: 'id' },
          { name: 'tags', type: 'array', properties:
            [
              { name: 'value' },
              { name: 'id' }
            ]
          }
        ]
      }
    },

    user: {
      fields: -> {
        [
          { name: "email", label: "User's Email" },
          { name: "firstName", label: "User's First Name" },
          { name: "lastName", label: "User's Last Name" },
          { name: "profilePicUrl", label: "User's Profile Pic" },
          { name: "userProfile", label: 'User Profile', type: 'object', properties:
            [
              { name: 'role', label: 'User Role' },
              { name: 'roleLevel', label: 'Role Level' }
            ]
          }
        ]
      }
    }
  },

  actions: {
    add_tag_to_card: {
      title: 'Add Tag to Card',
      subtitle: 'Adds an existing Tag to a Card.',
      description: "Adds an existing Tag to a Card.",

      input_fields: -> {
        [
          {
            name: 'cardId',
            label: 'Card Id',
            optional: false,
            type: 'string',
            hint: "Id of the Card to which to add the Tag"
          },
          {
            name: 'tagId',
            label: 'Tag ID',
            optional: false,
            type: 'string',
            hint: "Id of Tag you would like to add",
            control_type: 'select',
            pick_list: 'tags',
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'tagId',
              label: 'Tag ID',
              optional: false,
              type: 'string',
              control_type: 'text',
              toggle_hint: 'Enter Tag ID'
            }
          }
        ]
      },

      execute: -> (_connection, input) {
        put("cards/#{input['cardId']}/tags/#{input['tagId']}").after_error_response(/.*/) do |_code, body, _header, message|
          error("#{message}: #{body}")
        end.first
      },

      output_fields: -> (object_definitions) {
        object_definitions['empty']
      },
      sample_output: -> (_connection) { {} }
    },

    add_user_to_group: {
      title: 'Add User to Group',
      subtitle: 'Adds a user to a Group.',
      description: "Adds a user to a Group.",

      input_fields: -> {
        [
          {
            name: 'groupId',
            label: 'Group',
            optional: false,
            type: 'string',
            control_type: 'select',
            pick_list: 'groups',
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'groupId',
              label: 'Group ID',
              optional: false,
              type: 'string',
              control_type: 'text',
              toggle_hint: 'Enter Group ID'
            }
          },
          {
            name: 'memberId',
            label: 'Member ID',
            optional: false,
            type: 'string',
            hint: "The member's email address"
          }
        ]
      },
      execute: -> (_connection, input) {
        users = [{ user: { email: input['memberId'] } }]
        response = post("groups/#{input['groupId']}/members", users).after_error_response(/.*/) { |_code, body, _header, message|
          error("#{message}: #{body}")
        }.first
        { id: response['id'] }.merge(response['user'])
      },
      output_fields: -> (object_definitions) {
        object_definitions['user']
      },
      sample_output: -> (_connection) {
        {
          'id' => '0edc0ff7-0f1a-45de-b2f2-ff4466e6cab0',
          'status' => 'ACTIVE',
          'email' => 'test@test.com',
          'firstName' => 'TestFirst',
          'lastName' => 'TestLast',
          'profilePicUrl' => 'https://example.com/profile-pic'
        }
      }
    },

    archive_card: {
      title: 'Archive Card',
      subtitle: 'Archives a Card.',
      description: 'Archives a Card.',
      input_fields: -> (object_definitions) {
        object_definitions[:card_id_input]
      },
      execute: -> (_connection, input) {
        delete("cards/#{input['cardId']}").after_error_response(/.*/) { |_code, body, _header, message|
          error("#{message}: #{body}")
        }
      },
      output_fields: -> (object_definitions) {
        object_definitions['empty']
      },
      sample_output: -> (_connection) { {} }
    },

    create_card: {
      title: 'Create Card',
      subtitle: 'Create a new Card',
      description: "Create a new Card",
      input_fields: -> (object_definitions) {
        object_definitions['create_card_input']
      },
      execute: -> (_connection, input) {
        payload = {
          collection: { id: input['collectionId'] },
          boards: [{ id: input['boardId'] }],
          verifier: workato.parse_json(input['verifier']),
          tags: input['tagIds']&.map { |tagId| { id: tagId } }
        }
        payload = input.except('collectionId', 'boardId', 'tagIds').merge(payload)
        fact = post('facts/extended', payload).after_error_response(/.*/) { |_code, body, _header, message|
          error("#{message}: #{body}")
        }

        call('format_card', fact)
      },
      output_fields: -> (object_definitions) {
        object_definitions['card']
      },
      sample_output: -> (_connection) {
        call('format_card', get('search/query', maxResults: 1).first)
      }
    },

    create_group: {
      title: 'Create Group',
      subtitle: 'Creates a new Group',
      description: "Creates a new Group",
      input_fields: -> (_object_definitions) {
        {
          name: 'name',
          label: 'Group Name',
          optional: false
        }
      },
      execute: -> (_connection, input) {
        post('groups', input).after_error_response(/.*/) { |_code, body, _header, message|
          error("#{message}: #{body}")
        }
      },
      output_fields: -> (object_definitions) {
        object_definitions['group']
      },
      sample_output: -> (_connection) {
        {
          "id": "df8aa203-0dff-4839-9c8f-9002aed3e8d9",
          "dateCreated": "2021-05-07T14:53:20.760+0000",
          "groupIdentifier": "team",
          "numberOfCardsAsVerifier": 0,
          "numberOfMembers": 0,
          "modifiable": false,
          "name": "All Members"
        }
      }
    },

    create_tag: {
      title: 'Create Tag',
      subtitle: 'Create a Tag',
      description: "Create a Tag",
      input_fields: -> {
        [
          {
            name: 'value',
            label: 'Tag name',
            optional: false
          },
          {
            name: 'categoryId',
            label: 'Tag category',
            optional: false,
            control_type: 'select',
            pick_list: 'tag_categories',
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'categoryId',
              label: 'Tag category ID',
              optional: false,
              type: 'string',
              control_type: 'text',
              toggle_hint: 'Enter Tag category ID'
            }
          }
        ]
      },
      execute: -> (_connection, input) {
        post("teams/myteam/tagcategories/tags", input).after_error_response(/.*/) do |_code, body, _header, message|
          error("#{message}: #{body}")
        end
      },
      output_fields: -> (object_definitions) {
        object_definitions['tag']
      },
      sample_output: -> (_connection) {
        {
          "id": "d30e7865-bf0b-416e-871a-b7ed6738b652",
          "value": "TestTag"
        }
      }
    },

    create_tag_category: {
      title: 'Create Tag Category',
      subtitle: 'Create a Tag Category',
      description: "Create a Tag Category",
      input_fields: -> {
        [
          {
            name: 'name',
            label: 'Category name',
            optional: false
          }
        ]
      },
      execute: -> (_connection, input) {
        post("teams/myteam/tagcategories", input).after_error_response(/.*/) do |_code, body, _header, message|
          error("#{message}: #{body}")
        end
      },
      output_fields: -> (object_definitions) {
        object_definitions['tag_category'].ignored('tags')
      },
      sample_output: -> (_connection) {
        {
          "id": "b500915a-8a40-4a1f-9eca-f300f4981096",
          "name": "Test Tag Group"
        }
      }
    },

    get_board: {
      title: 'Get Board Details',
      subtitle: 'Get Board details',
      description: "Get Board details",
      input_fields: -> {
        [
          {
            name: 'boardId',
            label: 'Board ID',
            optional: false
          }
        ]
      },
      execute: -> (_connection, input) {
        board = get("boards/#{input['boardId']}").after_error_response(/.*/) { |_code, body, _header, message|
          error("#{message}: #{body}")
        }

        call('format_board', board)
      },
      output_fields: -> (object_definitions) {
        object_definitions['board']
      },
      sample_output: -> (_connection) {
        call('format_board', get('/boards').first)
      }
    },

    get_card: {
      title: 'Get Card Details',
      subtitle: 'Get Card details',
      description: "Get Card details",
      input_fields: -> {
        [
          { name: 'cardId',
            label: 'Card ID',
            optional: false,
            toggle_hint: 'Card ID',
            toggle_field: {
              name: 'cardTitle',
              label: 'Card Title',
              type: 'string',
              control_type: 'text',
              optional: false,
              toggle_hint: 'Enter Card Title'
            },
          }
        ]
      },
      execute: -> (_connection, input) {
        if input['cardId'] != nil
          card = get("facts/#{input['cardId']}/extended").after_error_response(/.*/) { |_code, body, _header, message|
            error("#{message}: #{body}")
          }
        else
          payload = {
            query: nil,
            searchTerms: input['cardTitle'],
            collectionIds: [],
            queryType: 'cards',
            untransformedSearchParams: [
              {
                type: "text",
                value: input['cardTitle'],
              },
            ],
          }
          card = post('search/query', payload).after_error_response(/.*/) { |_code, body, _header, message|
            error("#{message}: #{body}")
          }.first
        end
        call('format_card', card)
      },
      output_fields: -> (object_definitions) {
        object_definitions['card']
      },
      sample_output: -> (_connection) {
        call('format_card', get('search/query', maxResults: 1).first)
      }
    },

    get_collection: {
      title: 'Get Collection Details',
      subtitle: 'Get Collection details',
      description: "Get Collection details",
      input_fields: -> {
        [
          {
            name: 'collection_id',
            label: 'Collection',
            optional: false,
            type: 'string',
            control_type: 'select',
            pick_list: 'collections',
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'collection_id',
              label: 'Collection ID',
              optional: false,
              type: 'string',
              control_type: 'text',
              toggle_hint: 'Enter collection ID'
            }
          }
        ]
      },
      execute: -> (_connection, input) {
        collection = get("collections/#{input['collection_id']}").after_error_response(/.*/) do |_code, body, _header, message|
          error("#{message}: #{body}")
        end
        call('format_collection', collection)
      },
      output_fields: -> (object_definitions) {
        object_definitions['collection']
      },
      sample_output: -> (_connection) {
        call('format_collection', get('collections').first)
      }
    },

    get_group: {
      title: 'Get Group Details',
      subtitle: 'Get Group details. Use this Action with the New Group Created Trigger',
      description: 'Get Group details',
      input_fields: -> {
        [
          {
            name: 'group_id',
            label: 'Group Name',
            optional: false,
            type: 'string',
            control_type: 'select',
            pick_list: 'groups',
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'group_id',
              label: 'Group ID',
              optional: false,
              type: 'string',
              control_type: 'text',
              toggle_hint: 'Enter group ID'
            }
          }
        ]
      },
      execute: -> (_connection, input) {
        get("groups/#{input['group_id']}").after_error_response(/.*/) { |_code, body, _header, message|
          error("#{message}: #{body}")
        }
      },
      output_fields: -> (object_definitions) {
        object_definitions['group']
      },
      sample_output: -> (_connection) {
        get('groups').first
      }
    },

    get_tag: {
      title: 'Get Tag Details',
      subtitle: 'Get Tag details',
      description: "Get Tag details",
      input_fields: -> {
        [
          {
            name: 'tagId',
            label: 'Tag ID',
            optional: false,
            type: 'string',
            hint: "Id of Tag you would like to add",
            control_type: 'select',
            pick_list: 'tags',
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'tagId',
              label: 'Tag ID',
              optional: false,
              type: 'string',
              control_type: 'text',
              toggle_hint: 'Enter Tag ID'
            }
          }
        ]
      },
      execute: -> (_connection, input) {
        get("teams/myteam/tagcategories/tags/#{input['tagId']}").after_error_response(/.*/) { |_code, body, _header, message|
          error("#{message}: #{body}")
        }
      },
      output_fields: -> (object_definitions) {
        object_definitions['tag']
      },
      sample_output: -> (_connection) {
        tag_id = get("teams/myteam/tagcategories").dig(0, 'tags', 0, 'id')
        get("teams/myteam/tagcategories/tags/#{tag_id}")
      }
    },

    get_team_stats: {
      title: 'Get Team Stats',
      subtitle: 'Get Team stats',
      description: "Get Team stats",
      execute: -> (_connection) {
        response = get("teams/myteam/stats").after_error_response(/.*/) do |_code, body, _header, message|
          error("#{message}: #{body}")
        end
        call('format_stats', response['stats'])
      },
      output_fields: -> (object_definitions) {
        object_definitions['stats']
      },
      sample_output: -> (_connection) {
        response = get("teams/myteam/stats")
        call('format_stats', response['stats'])
      }
    },

    get_user: {
      title: 'Get User Details',
      subtitle: 'Find User details. Use this Action with the User Added to Group Trigger',
      description: "Find User details",
      input_fields: -> {
        [
          {
            name: 'userId',
            label: 'User ID',
            optional: false,
            type: 'string',
            hint: "The user's email address"
          }
        ]
      },
      execute: -> (_connection, input) {
        get("members/#{input['userId']}").after_error_response(/.*/) { |_code, body, _header, message|
          error("#{message}: #{body}")
        }.dig('user')
      },
      output_fields: -> (object_definitions) {
        object_definitions['user']
      },
      sample_output: -> (_connection) {
        get('members').first.dig('user')
      }
    },

    invite_user: {
      title: 'Invite User',
      subtitle: 'Adds a user to your Team',
      description: "Adds a user to your Team",
      input_fields: -> {
        [
          {
            name: 'emails',
            label: 'User Email',
            optional: false,
            type: 'string',
            control_type: 'email',
            hint: "The user's email address to be invited."
          },
          {
            name: 'groupId',
            label: 'Group ID',
            optional: true,
            sticky: true,
            type: 'string',
            control_type: 'select',
            pick_list: 'groups',
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'groupId',
              label: 'Group ID',
              optional: true,
              type: 'string',
              control_type: 'text',
              toggle_hint: 'Enter Group ID'
            }
          },
          {
            name: 'inviteMessage',
            label: 'Message',
            optional: true,
            type: 'string',
            hint: "An optional message to include in the invite email (note: invite emails may be disabled, you can check here https://app.getguru.com/settings/email-preferences)"
          }
        ]
      },
      execute: -> (_connection, input) {
        post('members/invite', input).
          after_error_response do |_code, body, _headers, message|
          error("#{message}: #{body}")
        end
      },
      output_fields: -> (_object_definitions) {
        [
          {
            name: 'statuses', type: 'array', of: 'object', properties:
            [
              { name: 'errored', type: 'boolean' },
              { name: 'error' },
              { name: 'email', control_type: 'email' }
            ]
          }
        ]
      }
    },

    list_tag_categories: {
      title: 'List Tag Categories',
      subtitle: 'List Tag Categories',
      description: "List Tag Categories",
      input_fields: -> (_object_definitions) {
        [
          {
            name: 'token',
            label: 'Pagination Token',
            type: 'string',
            hint: 'Use <b>Link</b> from previous output to navigate.',
            optional: true,
            sticky: true
          }
        ]
      },
      execute: -> (_connection, input) {
        get(input.present? ? input['token'] : "teams/myteam/tagcategories").
          after_response do |_code, body, headers|
          {
            link: headers['link'].present? ? headers['link'].split(';').first[1..-2] : nil,
            tag_categories: (body.presence || [])
          }
        end
      },
      output_fields: -> (object_definitions) {
        [
          { name: 'link' },
          { name: 'tag_categories', type: 'array', of: 'object',
            properties: object_definitions['tag_category'].ignored('dateCreated', 'createdBy') }
        ]
      },
      sample_output: -> (_connection, _input) {
        get("teams/myteam/tagcategories").
          after_response do |_code, body, headers|
          {
            link: headers['link'].present? ? headers['link'].split(';').first[1..-2] : nil,
            tag_categories: (body.presence || [])
          }
        end
      }
    },

    list_collections: {
      title: 'List Collections',
      subtitle: 'List Collections',
      description: "List Collections",
      input_fields: -> (_object_definitions) {
        [
          {
            name: 'token',
            label: 'Pagination Token',
            type: 'string',
            hint: 'Use <b>Link</b> from previous output to navigate.',
            optional: true,
            sticky: true
          }
        ]
      },
      execute: -> (_connection, input) {
        get(input.present? ? input['token'] : 'collections').after_response do |_code, body, headers|
          {
            link: headers['link'].present? ? headers['link'].split(';').first[1..-2] : '',
            collections: body&.map { |collection| call('format_collection', collection) }
          }
        end
      },
      output_fields: -> (object_definitions) {
        [
          { name: 'link' },
          { name: 'collections', type: 'array', of: 'object', properties: object_definitions['collection'] }
        ]
      },
      sample_output: -> (_connection) {
        {
          link: headers['link'].present? ? headers['link'].split(';').first[1..-2] : '',
          collections: get('collections').map { |collection| call('format_collection', collection) }
        }
      }
    },

    list_members_within_group: {
      title: 'List Group Members',
      subtitle: 'List Users within a Group',
      description: "List Users within a Group",
      input_fields: -> (_object_definitions) {
        [
          {
            name: 'groupId',
            label: 'Group',
            optional: false,
            type: 'string',
            control_type: 'select',
            pick_list: 'groups',
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'groupId',
              label: 'Group ID',
              optional: false,
              type: 'string',
              control_type: 'text',
              toggle_hint: 'Enter Group ID'
            }
          },
          {
            name: 'token',
            label: 'Pagination Token',
            type: 'string',
            hint: 'Use <b>Link</b> from previous output to navigate.',
            optional: true,
            sticky: true
          }
        ]
      },
      execute: -> (_connection, input) {
        get(input['token'].present? ? input['token'] : "groups/#{input['groupId']}/members").
          after_response do |_code, body, headers|
          response = body&.map do |member|
            { id: member['id'], dateCreated: member['dateCreated'] }.merge(member['user'])
          end
          {
            link: headers['link'].present? ? headers['link'].split(';').first[1..-2] : '',
            members: (response.presence || [])
          }
        end
      },
      output_fields: -> (object_definitions) {
        [
          { name: 'link' },
          { name: 'members', type: 'array', of: 'object', properties: object_definitions['user'] }
        ]
      },
      sample_output: -> (_connection) {
        {
          'link': 'https://app.getguru.com/groups/<groupId>/members?token=<token>',
          'members': [
            {
              "id": "test@test.com",
              "status": "ACTIVE",
              "lastName": "TestLast",
              "firstName": "TestFirst",
              "profilePicUrl": "https://example.com/profile-pic"
            }
          ]
        }
      }
    },

    restore_card: {
      title: 'Restore Card',
      subtitle: 'Restores a previously Archived Card',
      description: 'Restores a previously Archived Card',
      input_fields: -> {
        [
          { name: 'cardId',
            label: 'Card ID',
            optional: false,
            toggle_hint: 'Card ID',
            toggle_field: {
              name: 'cardTitle',
              label: 'Card Title',
              type: 'string',
              control_type: 'text',
              optional: false,
              toggle_hint: 'Card Title'
            },
          }
        ]
      },
      execute: -> (_connection, input) {
        card_id_to_restore = input['cardId'] if input['cardId'].present?

        if input['cardTitle'].present?
          payload_find_archived_card_by_title = {
            queryType: 'archived',
            showArchived: true,
            query: {
              nestedExpressions: [
                {
                  type: 'title',
                  op: 'IS',
                  value: input['cardTitle']
                }
              ],
              op: 'AND',
              type: 'grouping'
            }
          }

          card_id_to_restore = post('search/cardmgr', payload_find_archived_card_by_title)
                                 .after_error_response(/.*/) { |_code, body, _header, message|
                                   error("#{message}: #{body}")
                                 }&.first&.[]('id')
          error('Card Not Found') unless card_id_to_restore.present?
        end

        payload_restore_archived_card_by_id = {
          action: {
            type: 'restore-archived-card',
          },
          items: {
            type: 'id',
            cardIds: [card_id_to_restore],
          },
        }

        bulk_op_response = post('cards/bulkop', payload_restore_archived_card_by_id)
                             .after_error_response(/.*/) { |_code, body, _header, message|
                               error("#{message}: #{body}")
                             }
        card_response = bulk_op_response&.dig('items', 0)

        if (card_response['statusCode'] == 200 || card_response['statusCode'] == 204)
          {}
        else
          error("#{card_response['statusCode']}: #{card_response['responseMessage']}")
        end
      },
      output_fields: -> (object_definitions) {
        object_definitions['empty']
      },
      sample_output: -> (_connection) { {} }
    },

    remove_group_member: {
      title: 'Remove User from Group',
      subtitle: 'Removes a User from a Group',
      description: "Removes a User from a Group",
      input_fields: -> {
        [
          {
            name: 'groupId',
            label: 'Group Name',
            optional: false,
            type: 'string',
            control_type: 'select',
            pick_list: 'groups',
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'groupId',
              label: 'Group ID',
              optional: false,
              type: 'string',
              control_type: 'text',
              toggle_hint: 'Enter Group ID'
            }
          },
          {
            name: 'memberId',
            label: 'User Email',
            optional: false,
            type: 'string',
            hint: "The email address of the user you're removing from the specified Group."
          }
        ]
      },
      execute: -> (_connection, input) {
        delete("groups/#{input['groupId']}/members/#{input['memberId']}").
          after_error_response(/.*/) do |_code, body, _header, message|
          error("#{message}: #{body}")
        end
      }
    },

    remove_team_member: {
      title: 'Remove User',
      subtitle: 'Removes a User from your Team',
      description: "Removes a User from your Team",
      input_fields: -> {
        [
          { name: 'email',
            label: 'User Email',
            optional: false,
            control_type: 'email',
            hint: "The email address of the user you're removing from your team." }
        ]
      },
      execute: -> (_connection, input) {
        delete("members/#{input['email']}").
          after_error_response(/.*/) do |_code, body, _header, message|
          error("#{message}: #{body}")
        end
      }
    },

    search_archive_card: {
      title: 'Search for Archived Card',
      subtitle: 'Search for a card that has been archived',
      description: 'Search for a card that has been archived',

      input_fields: -> {
        [
          {
            name: 'title',
            label: 'Card Title',
            optional: false,
            type: 'string',
            hint: 'Card title to search for in archived cards.'
          }
        ]
      },

      execute: -> (_connection, input) {
        payload = {
          queryType: 'archived',
          showArchived: true,
          query: {
            nestedExpressions: [
              {
                type: 'title',
                op: 'IS',
                value: input['title']
              }
            ],
            op: 'AND',
            type: 'grouping'
          }
        }

        card = post('search/cardmgr', payload).after_error_response(/.*/) { |_code, body, _header, message|
          error("#{message}: #{body}")
        }&.first

        if card.present?
          call('format_card', card)
        else
          error "Could not find archived card."
        end
      },

      output_fields: -> (object_definitions) {
        object_definitions['card']
      },
      sample_output: -> (_connection) {
        call('format_card', get('search/query', maxResults: 1).first)
      }
    },

    search_cards: {
      title: 'Search Cards',
      subtitle: 'Search Cards.',
      description: "Search Cards",
      input_fields: -> (object_definitions) {
        object_definitions['search_cards_input']
      },
      execute: -> (_connection, input) {
        if input['token'].present?
          get(input['token'])
        else
          get('search/query', input)
        end.after_response do |_code, body, headers|
          {
            link: headers['link'].present? ? headers['link'].split(';').first[1..-2] : '',
            cards: (body.presence || []).map { |card| call('format_card', card) }
          }
        end
      },
      output_fields: -> (object_definitions) {
        [
          { name: 'link' },
          { name: 'cards', type: 'array', of: 'object', properties: object_definitions['card'] }
        ]
      },
      sample_output: -> (_connection) {
        get('search/query', maxResults: 1).after_response do |_code, body, headers|
          {
            link: headers['link'].present? ? headers['link'].split(';').first[1..-2] : '',
            cards: (body.presence || []).map { |card| call('format_card', card) }
          }
        end
      }
    },

    search_groups: {
      title: 'Search Groups',
      subtitle: 'Search Groups',
      description: "Search Groups",
      input_fields: -> {
        [
          {
            name: 'search',
            label: 'Group Name',
            optional: true,
            sticky: true,
            hint: 'Return groups that contain the search term. Leave blank to list all groups.'
          }
        ]
      },
      execute: -> (_connection, input) {
        response = get('groups', input).
          after_error_response(/.*/) do |_code, body, _header, message|
          error("#{message}: #{body}")
        end

        { groups: response }
      },
      output_fields: -> (object_definitions) {
        [
          { name: 'groups', type: 'array', of: 'object', properties: object_definitions['group'] }
        ]
      },
      sample_output: -> (_connection) {
        { groups: get('groups') }
      }
    },

    unverify_card: {
      title: 'Unverify Card',
      subtitle: 'Unverifies a Card',
      description: 'Unverifies a Card',
      input_fields: -> (object_definitions) {
        object_definitions[:card_id_input]
      },
      execute: -> (_connection, input) {
        post("cards/#{input['cardId']}/unverify").
          after_error_response(/.*/) { |_code, body, _header, message|
            error("#{message}: #{body}")
          }
      },
      output_fields: -> (object_definitions) {
        object_definitions['empty']
      },
      sample_output: -> (_connection) { {} }
    },

    update_card: {
      title: 'Update Card',
      subtitle: 'Update a Card',
      description: "Update a Card",
      input_fields: -> (object_definitions) {
        [{ name: 'cardId', hint: 'The card ID to update.', optional: false }].
          concat(object_definitions['create_card_input'])
      },
      execute: -> (_connection, input) {
        payload = input.except('collectionId').merge({ collection: { id: input['collectionId'] } })
        card = put("facts/#{input['cardId']}/extended", payload).after_error_response(/.*/) do |_code, body, _header, message|
          error("#{message}: #{body}")
        end
        call('format_card', card)
      },
      output_fields: -> (object_definitions) {
        object_definitions['card']
      },
      sample_output: -> (_connection) {
        call('format_card', get('search/query', maxResults: 1).first)
      }
    },

    verify_card: {
      title: 'Verify Card',
      subtitle: 'Verifies a Card',
      description: 'Verifies a Card',
      input_fields: -> (object_definitions) {
        object_definitions[:card_id_input]
      },
      execute: -> (_connection, input) {
        put("cards/#{input['cardId']}/verify").
          after_error_response(/.*/) { |_code, body, _header, message|
            error("#{message}: #{body}")
          }
      },
      output_fields: -> (object_definitions) {
        object_definitions['empty']
      },
      sample_output: -> (_connection) { {} }
    }
  },

  triggers: {
    collection_trust_score_change: {
      title: 'Collection Trust Score Change',
      subtitle: "Triggers when the selected collection's trust score changes",
      description: "Triggers when the selected collection's trust score changes",
      help: "Triggers when the selected collection's trust score changes.",
      input_fields: -> (_object_definitions) {
        [
          {
            name: 'collectionId',
            label: 'Collection',
            control_type: 'select',
            pick_list: 'collections',
            optional: false,
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'collectionId',
              label: 'Collection ID',
              type: 'string',
              control_type: 'text',
              optional: false,
              toggle_hint: 'Enter Collection ID'
            }
          },
          {
            name: 'threshold',
            label: 'Trust Score Threshold',
            type: 'integer',
            control_type: 'integer',
            hint: 'Trust score threshold between 0 and 100.',
            default: '100',
            render_input: 'integer_conversion',
            parse_output: 'integer_conversion',
            optional: false
          }
        ]
      },

      poll: -> (_connection, input, closure) {
        closure = {} unless closure.present?

        collection = get("collections").select { |c| c['id'] == input['collectionId'] }.first
        stats = call('format_stats', collection.dig('collectionStats', 'stats'))
        threshold = input['threshold'].to_i
        last_trust_score = closure['cursor'].present? ? closure['cursor'] : threshold

        was_below = last_trust_score < threshold
        is_below = stats['trustScore'] < threshold

        if is_below != was_below
          direction = is_below ? 'below' : 'above'
          data = {
            :id => "#{direction}_#{now}",
            :direction => direction,
            :threshold => threshold,
            :trustScore => stats['trustScore'],
            :verifiedCards => stats['verified'],
            :unverifiedCards => stats['unverified'],
            :totalCards => stats['cardCount'],
            :collectionUrl => call('format_collection_url', collection['slug']),
            :collectionName => collection['name']
          }

          if is_below
            data['cardsToGoal'] = ((stats['cardCount'] * (threshold - stats['trustScore'])) / 100).to_i
            cards = get("search/query/unverified?maxResults=#{stats['cardCount']}&collectionId=#{input['collectionId']}")

            top_verifiers = []
            cards.map { |card|
              card[:verifiers]&.map { |v|
                "#{v[:user][:firstName]} #{v[:user][:lastName]}"
              }
            }.flatten.each { |verifier|
              top_verifier = top_verifiers.select { |v| v[:name] = verifier }.first
              if top_verifier.nil?
                top_verifier = { :name => verifier, :count => 0 }
                top_verifiers.insert(0, top_verifier)
              end
              top_verifier[:count] = top_verifier[:count] + 1
            }

            top_verifiers.sort { |x, y| x[:count] <=> y[:count] }.first(3).each_with_index do |v, i|
              data["topVerifier#{i + 1}"] = v[:name]
              data["topVerifierCards#{i + 1}"] = v[:count]
            end
          end

          events = [data]
          closure['cursor'] = stats['trustScore']
        end

        {
          events: events,
          next_poll: closure,
          can_poll_more: false
        }
      },

      dedup: -> (processed_message) {
        processed_message['id']
      },

      output_fields: -> (object_definitions) {
        object_definitions['collection_trust_score']
      },

      sample_output: -> {
        {
          id: "above_123",
          direction: "above",
          threshold: 85,
          trustScore: 90,
          verifiedCards: 9,
          unverifiedCards: 1,
          totalCards: 10,
          collectionUrl: "https://app.getguru.com/collections/12345/General",
          collectionName: "General",
          topVerifier1: "Allen Iverson",
          topVerifierCards1: 50,
          topVerifier2: "Julius Erving",
          topVerifierCards2: 40,
          topVerifier3: "Joel Embiid",
          topVerifierCards_3: 20,
        }
      }
    },

    new_board_created: {
      title: 'New Board Created',
      subtitle: 'Triggers when a new Board is created',
      description: 'Triggers when a new Board is created',
      help: 'Triggers when a new Board is created.',

      webhook_subscribe: -> (webhook_url, _connection, _input, _recipe_id) {
        call('create_webhook', webhook_url, 'board-created')
      },

      webhook_notification: -> (_input, payload, _extended_input_schema, _extended_output_schema, _headers, _params) {
        batch = payload['items'] or payload['Items']
        messages = batch.map { |item| item['data'] }.map { |index| index['messages'] }.flatten
        events = messages.map { |item| workato.parse_json(item['data']) }
        {
          "id" => messages.map { |message| message['id'] }.join('|'),
          "results" => events
        }
      },

      webhook_unsubscribe: -> (webhook_subscribe_output) {
        call('delete_webhook', webhook_subscribe_output['id'])
      },

      dedup: -> (webhook_notification_output) {
        webhook_notification_output['id']
      },

      output_fields: -> (_object_definitions) {
        [
          {
            name: 'results', type: 'array', of: 'object', properties:
            [
              { name: 'id' },
              { name: 'eventType' },
              { name: 'eventDate' },
              { name: 'user' },
              {
                name: 'properties', type: 'object', properties:
                [
                  { name: 'source' },
                  { name: 'boardId' },
                  { name: 'collectionId' },
                ]
              }
            ]
          }
        ]
      },

      sample_output: -> (_connection) {
        {
          :results => [
            {
              :properties => {
                :source => 'UI',
                :boardId => 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
                :collectionId => 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
              },
              :id => 'cccccccc-cccc-cccc-cccc-cccccccccccc',
              :eventType => 'board-created',
              :user => 'user@getguru.com',
              :eventDate => '2021-05-17T16:50:40.391+0000'
            }
          ]
        }
      }
    },

    new_card_archived: {
      title: 'New Card Archived',
      subtitle: 'Triggers when a user archives a Card',
      description: 'Triggers when a user archives a Card',
      help: 'Triggers when a user archives a Card.',

      webhook_subscribe: -> (webhook_url, _connection, _input, _recipe_id) {
        call('create_webhook', webhook_url, 'card-deleted')
      },

      webhook_notification: -> (_input, payload, _extended_input_schema, _extended_output_schema, _headers, _params) {
        batch = payload['items'] or payload['Items']
        messages = batch.map { |item| item['data'] }.map { |index| index['messages'] }.flatten
        events = messages.map { |item| workato.parse_json(item['data']) }
        {
          "id" => messages.map { |message| message['id'] }.join('|'),
          "results" => events
        }
      },

      webhook_unsubscribe: -> (webhook_subscribe_output) {
        call('delete_webhook', webhook_subscribe_output['id'])
      },

      dedup: -> (webhook_notification_output) {
        webhook_notification_output['id']
      },

      output_fields: -> (object_definitions) {
        object_definitions[:default_card_trigger_output]
      },

      sample_output: -> (_connection) {
        call('default_card_sample_output', 'card-deleted')
      }
    },

    new_card_comment: {
      title: 'New Card Comment',
      subtitle: 'Triggers when a user comments on a Card',
      description: 'Triggers when a user comments on a Card',
      help: 'Triggers when a user comments on a Card.',

      webhook_subscribe: -> (webhook_url, _connection, _input, _recipe_id) {
        call('create_webhook', webhook_url, 'card-comment-created')
      },

      webhook_notification: -> (_input, payload, _extended_input_schema, _extended_output_schema, _headers, _params) {
        batch = payload['items'] or payload['Items']
        messages = batch.map { |item| item['data'] }.map { |index| index['messages'] }.flatten
        events = messages.map { |item| workato.parse_json(item['data']) }
        {
          "id" => messages.map { |message| message['id'] }.join('|'),
          "results" => events
        }
      },

      webhook_unsubscribe: -> (webhook_subscribe_output) {
        call('delete_webhook', webhook_subscribe_output['id'])
      },

      dedup: -> (webhook_notification_output) {
        webhook_notification_output['id']
      },

      output_fields: -> (_object_definitions) {
        [
          {
            name: 'results', type: 'array', of: 'object', properties:
            [
              { name: 'id' },
              { name: 'eventType' },
              { name: 'eventDate' },
              { name: 'user' },
              { name: 'properties', type: 'object', properties:
                [
                  { name: 'cardId' },
                  { name: 'commentId' },
                  { name: 'source' },
                  { name: 'collectionId' },
                ]
              }
            ]
          }
        ]
      },

      sample_output: -> (_connection) {
        {
          :results => [
            {
              :properties => {
                :cardId => 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
                :commentId => 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
                :source => 'UI',
                :collectionId => 'cccccccc-cccc-cccc-cccc-cccccccccccc',
              },
              :id => 'dddddddd-dddd-dddd-dddd-dddddddddddd',
              :eventType => 'card-comment-created',
              :user => 'user@getguru.com',
              :eventDate => '2021-05-17T16:50:40.391+0000'
            }
          ]
        }
      }
    },

    new_card_copied: {
      title: 'New Card Copied',
      subtitle: 'Triggers when a user either copies the content within the Card or clicks on the "Card Copied content" button',
      description: 'Triggers when a user either copies the content within the Card or clicks on the "Card Copied content" button',
      help: 'Triggers when a user either copies the content within the Card or clicks on the "Card Copied content" button.',

      webhook_subscribe: -> (webhook_url, _connection, _input, _recipe_id) {
        call('create_webhook', webhook_url, 'card-copied')
      },

      webhook_notification: -> (_input, payload, _extended_input_schema, _extended_output_schema, _headers, _params) {
        batch = payload['items'] or payload['Items']
        messages = batch.map { |item| item['data'] }.map { |index| index['messages'] }.flatten
        events = messages.map { |item| workato.parse_json(item['data']) }
        {
          "id" => messages.map { |message| message['id'] }.join('|'),
          "results" => events
        }
      },

      webhook_unsubscribe: -> (webhook_subscribe_output) {
        call('delete_webhook', webhook_subscribe_output['id'])
      },

      dedup: -> (webhook_notification_output) {
        webhook_notification_output['id']
      },

      output_fields: -> (object_definitions) {
        object_definitions[:default_card_trigger_output]
      },

      sample_output: -> (_connection) {
        call('default_card_sample_output', 'card-copied')
      }
    },

    new_card_created: {
      title: 'New Card Created',
      subtitle: 'Triggers when a new Card is published',
      description: 'Triggers when a new Card is published',
      help: 'Triggers when a new Card is published.',

      webhook_subscribe: -> (webhook_url, _connection) {
        call('create_webhook', webhook_url, 'card-created')
      },

      webhook_notification: -> (_input, payload, _extended_input_schema, _extended_output_schema, _headers, _params) {
        messages_array = payload['items'].map { |item|
          item['data'] }.map { |index|
          index['messages'] }.flatten.map { |message|
          workato.parse_json(message['data']) }

        {
          "id" => messages_array.map { |message| message['id'] }.join('|'),
          "results" => messages_array
        }
      },

      webhook_unsubscribe: -> (webhook_subscribe_output) {
        call('delete_webhook', webhook_subscribe_output['id'])
      },

      dedup: -> (webhook_notification_output) {
        webhook_notification_output['id']
      },

      output_fields: -> (object_definitions) {
        object_definitions[:default_card_trigger_output]
      },

      sample_output: -> (_connection) {
        call('default_card_sample_output', 'card-created')
      }
    },

    new_card_favorited: {
      title: 'New Card Favorited',
      subtitle: 'Triggers when a user clicks the heart icon to add the card to "My Favorite Card" list',
      description: 'Triggers when a user clicks the heart icon to add the card to "My Favorite Card" list',
      help: 'Triggers when a user clicks the heart icon to add the card to "My Favorite Card" list.',
      webhook_subscribe: -> (webhook_url, _connection, _input, _recipe_id) {
        call('create_webhook', webhook_url, 'card-favorited')
      },
      webhook_notification: -> (_input, payload, _extended_input_schema, _extended_output_schema, _headers, _params) {
        batch = payload['items'] or payload['Items']
        messages = batch.map { |item| item['data'] }.map { |index| index['messages'] }.flatten
        events = messages.map { |item| workato.parse_json(item['data']) }
        {
          "id" => messages.map { |message| message['id'] }.join('|'),
          "results" => events
        }
      },

      dedup: -> (webhook_notification_output) {
        webhook_notification_output['id']
      },

      webhook_unsubscribe: -> (webhook_subscribe_output) {
        call('delete_webhook', webhook_subscribe_output['id'])
      },

      output_fields: -> (object_definitions) {
        object_definitions[:default_card_trigger_output]
      },

      sample_output: -> (_connection) {
        call('default_card_sample_output', 'card-favorited')
      }
    },

    new_card_link_copied: {
      title: 'New Card Link Copied',
      subtitle: 'Triggers when a user clicks on the "Card Copy link" button',
      description: 'Triggers when a user clicks on the "Card Copy link" button',
      help: 'Triggers when a user clicks on the "Card Copy link" button.',

      webhook_subscribe: -> (webhook_url, _connection, _input, _recipe_id) {
        call('create_webhook', webhook_url, 'card-link-copied')
      },

      webhook_notification: -> (_input, payload, _extended_input_schema, _extended_output_schema, _headers, _params) {
        batch = payload['items'] or payload['Items']
        messages = batch.map { |item| item['data'] }.map { |index| index['messages'] }.flatten
        events = messages.map { |item| workato.parse_json(item['data']) }
        {
          "id" => messages.map { |message| message['id'] }.join('|'),
          "results" => events
        }
      },

      webhook_unsubscribe: -> (webhook_subscribe_output) {
        call('delete_webhook', webhook_subscribe_output['id'])
      },

      dedup: -> (webhook_notification_output) {
        webhook_notification_output['id']
      },

      output_fields: -> (object_definitions) {
        object_definitions[:default_card_trigger_output]
      },

      sample_output: -> (_connection) {
        call('default_card_sample_output', 'card-link-copied')
      }
    },

    new_card_unfavorited: {
      title: 'New Card Unfavorited',
      subtitle: 'Triggers when a user removes a Card from their "My Favorite Card" list',
      description: 'Triggers when a user removes a Card from their "My Favorite Card" list',
      help: 'Triggers when a user removes a Card from their "My Favorite Card" list.',

      webhook_subscribe: -> (webhook_url, _connection, _input, _recipe_id) {
        call('create_webhook', webhook_url, 'card-unfavorited')
      },

      webhook_notification: -> (_input, payload, _extended_input_schema, _extended_output_schema, _headers, _params) {
        batch = payload['items'] or payload['Items']
        messages = batch.map { |item| item['data'] }.map { |index| index['messages'] }.flatten
        events = messages.map { |item| workato.parse_json(item['data']) }
        {
          "id" => messages.map { |message| message['id'] }.join('|'),
          "results" => events
        }
      },

      webhook_unsubscribe: -> (webhook_subscribe_output) {
        call('delete_webhook', webhook_subscribe_output['id'])
      },

      dedup: -> (webhook_notification_output) {
        webhook_notification_output['id']
      },

      output_fields: -> (object_definitions) {
        object_definitions[:default_card_trigger_output]
      },

      sample_output: -> (_connection) {
        call('default_card_sample_output', 'card-unfavorited')
      }
    },

    new_card_unverified: {
      title: 'New Card Unverified',
      subtitle: 'Triggers when a Card becomes unverified',
      description: 'Triggers when a Card becomes unverified',
      help: 'Triggers when a Card becomes unverified.',
      input_fields: -> (object_definitions) {
        object_definitions[:optional_collection_board_dropdown]
      },

      poll: -> (_connection, input, closure) {
        response =
          if closure&.[]('next_page').present?
            get(closure['next_page']).after_response { |_code, body, headers|
              call('search_query_pagination_response', headers, body)
            }
          else
            if (input[:collectionId]).present?
              params = { "collectionId" => input[:collectionId] }
            end

            get('search/query/unverified', params).after_response { |_code, body, headers|
              call('search_query_pagination_response', headers, body)
            }
          end

        if (input[:boardId]).present?
          cards_on_board = []
          response[:cards]&.each { |card|
            card['boards']&.each { |board|
              if board['id'] == input[:boardId]
                cards_on_board.push(card)
              end
            }
          }
          response[:cards] = cards_on_board
        end

        closure = { next_page: response[:next_page] } unless response[:next_page].blank?

        {
          events: response[:cards],
          next_poll: closure,
          can_poll_more: response[:next_page].present?
        }
      },

      dedup: -> (processed_message) {
        "#{processed_message[:id]}|#{processed_message[:lastVerified]}"
      },

      output_fields: -> (object_definitions) {
        object_definitions[:card]
      },

      sample_output: -> {
        call('format_card', get('search/query/unverified', maxResults: 1)&.first)
      }
    },

    new_card_updated: {
      title: 'New Card Updated',
      subtitle: 'Triggers when a user makes an edit to a Card',
      description: "Triggers when a user makes an edit to a Card",
      help: 'Triggers when a user makes an edit to a Card.',

      webhook_subscribe: -> (webhook_url, _connection) {
        call('create_webhook', webhook_url, 'card-updated')
      },

      webhook_notification: -> (_input, payload, _extended_input_schema, _extended_output_schema, _headers, _params) {
        messages_array = payload['items'].map { |item|
          item['data'] }.map { |index|
          index['messages'] }.flatten.map { |message|
          workato.parse_json(message['data']) }

        {
          "id" => messages_array.map { |message| message['id'] }.join('|'),
          "results" => messages_array
        }
      },

      webhook_unsubscribe: -> (webhook_subscribe_output) {
        call('delete_webhook', webhook_subscribe_output['id'])
      },

      dedup: -> (webhook_notification_output) {
        webhook_notification_output['id']
      },

      output_fields: -> (object_definitions) {
        object_definitions[:default_card_trigger_output]
      },

      sample_output: -> (_connection) {
        call('default_card_sample_output', 'card-updated')
      }
    },

    new_card_verified: {
      title: 'New Card Verified',
      subtitle: 'Triggers when a user verifies a Card',
      description: 'Triggers when a user verifies a Card',
      help: 'Triggers when a user verifies a Card.',

      webhook_subscribe: -> (webhook_url, _connection) {
        call('create_webhook', webhook_url, 'card-verified')
      },

      webhook_notification: -> (_input, payload, _extended_input_schema, _extended_output_schema, _headers, _params) {
        messages_array = payload['items'].map { |item|
          item['data'] }.map { |index|
          index['messages'] }.flatten.map { |message|
          workato.parse_json(message['data']) }

        {
          "id" => messages_array.map { |message| message['id'] }.join('|'),
          "results" => messages_array
        }
      },

      webhook_unsubscribe: -> (webhook_subscribe_output) {
        call('delete_webhook', webhook_subscribe_output['id'])
      },

      dedup: -> (webhook_notification_output) {
        webhook_notification_output['id']
      },

      output_fields: -> (object_definitions) {
        object_definitions[:default_card_trigger_output]
      },

      sample_output: -> (_connection) {
        call('default_card_sample_output', 'card-verified')
      }
    },

    new_card_viewed: {
      title: 'New Card Viewed',
      subtitle: 'Triggers when a user views a Card',
      description: 'Triggers when a user views a Card',
      help: 'Triggers when a user views a Card.',

      webhook_subscribe: -> (webhook_url, _connection, _input, _recipe_id) {
        call('create_webhook', webhook_url, 'card-viewed')
      },

      webhook_notification: -> (_input, payload, _extended_input_schema, _extended_output_schema, _headers, _params) {
        batch = payload['items'] or payload['Items']
        messages = batch.map { |item| item['data'] }.map { |index| index['messages'] }.flatten
        events = messages.map { |item| workato.parse_json(item['data']) }
        {
          "id" => messages.map { |message| message['id'] }.join('|'),
          "results" => events
        }
      },

      webhook_unsubscribe: -> (webhook_subscribe_output) {
        call('delete_webhook', webhook_subscribe_output['id'])
      },

      dedup: -> (webhook_notification_output) {
        webhook_notification_output['id']
      },

      output_fields: -> (_object_definitions) {
        [
          { name: 'results', type: 'array', of: 'object', properties:
            [
              { name: 'id' },
              { name: 'eventType' },
              { name: 'eventDate' },
              { name: 'user' },
              { name: 'properties', type: 'object', properties:
                [
                  { name: 'activityId' },
                  { name: 'application' },
                  { name: 'cardId' },
                  { name: 'source' },
                  { name: 'activitySubType' },
                  { name: 'collectionId' },
                ]
              }
            ]
          }
        ]
      },

      sample_output: -> (_connection) {
        {
          :results => [
            {
              :properties => {
                :activityId => 'undefined',
                :application => 'webapp',
                :cardId => 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
                :source => 'UI',
                :activitySubType => 'new-content',
                :collectionId => 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
              },
              :id => 'cccccccc-cccc-cccc-cccc-cccccccccccc',
              :eventType => 'card-viewed',
              :user => 'user@getguru.com',
              :eventDate => '2021-05-17T16:50:40.391+0000'
            }
          ]
        }
      }
    },

    new_collection_created: {
      title: 'New Collection Created',
      subtitle: 'Triggers when a new Collection is created',
      description: 'Triggers when a new Collection is created',
      help: 'Triggers when a new Collection is created.',

      webhook_subscribe: -> (webhook_url, _connection, _input, _recipe_id) {
        call('create_webhook', webhook_url, 'collection-created')
      },

      webhook_notification: -> (_input, payload, _extended_input_schema, _extended_output_schema, _headers, _params) {
        batch = payload['items'] or payload['Items']
        messages = batch.map { |item| item['data'] }.map { |index| index['messages'] }.flatten
        events = messages.map { |item| workato.parse_json(item['data']) }
        {
          "id" => messages.map { |message| message['id'] }.join('|'),
          "results" => events
        }
      },

      webhook_unsubscribe: -> (webhook_subscribe_output) {
        call('delete_webhook', webhook_subscribe_output['id'])
      },

      dedup: -> (webhook_notification_output) {
        webhook_notification_output['id']
      },

      output_fields: -> (_object_definitions) {
        [
          { name: 'results', type: 'array', of: 'object', properties: [
            { name: 'id' },
            { name: 'eventType' },
            { name: 'eventDate' },
            { name: 'user' },
            { name: 'properties', type: 'object', properties:
              [
                { name: 'source' },
                { name: 'collectionId' },
              ]
            }
          ]
          }
        ]
      },

      sample_output: -> (_connection) {
        {
          :results => [
            {
              :properties => {
                :source => 'UI',
                :collectionId => 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
              },
              :id => 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
              :eventType => 'collection-created',
              :user => 'user@getguru.com',
              :eventDate => '2021-05-17T16:50:40.391+0000'
            }
          ]
        }
      }
    },

    new_group_created: {
      title: 'New Group Created',
      subtitle: 'Triggers when a new Group is published',
      description: 'Triggers when a new Group is published',
      help: 'Triggers when a new Group is published.',

      webhook_subscribe: -> (webhook_url, connection) {
        call('create_webhook', webhook_url, 'usergroup-created')
      },

      webhook_notification: -> (_input, payload, _extended_input_schema, _extended_output_schema, _headers, _params) {
        batch = payload['items'] or payload['Items']
        messages = batch.map { |item| item['data'] }.map { |index| index['messages'] }.flatten
        events = messages.map { |item| workato.parse_json(item['data']) }
        {
          "id" => messages.map { |message| message['id'] }.join('|'),
          "results" => events
        }
      },

      webhook_unsubscribe: -> (webhook_subscribe_output) {
        call('delete_webhook', webhook_subscribe_output['id'])
      },

      dedup: -> (webhook_notification_output) {
        webhook_notification_output['id']
      },

      output_fields: -> (_object_definitions) {
        [
          { name: 'results', type: 'array', of: 'object', properties: [
            { name: 'id' },
            { name: 'eventType' },
            { name: 'eventDate' },
            { name: 'user' },
            { name: 'properties', type: 'object', properties:
              [
                { name: 'userGroupId' },
                { name: 'source' },
              ]
            }
          ]
          }
        ]
      },

      sample_output: -> (_connection) {
        {
          "results" => [
            {
              "id": "cccccccc-cccc-cccc-cccc-cccccccccccc",
              "eventType": "usergroup-created",
              "eventDate": "2021-05-17T16:50:40.391+0000",
              "user": "user@getguru.com",
              "properties": {
                "userGroupId": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
                "source": "UI"
              }
            }
          ]
        }
      }
    },

    new_tag_created: {
      title: 'New Tag Created',
      subtitle: 'Triggers when a new Tag is created',
      description: 'Triggers when a new Tag is created',
      help: 'Triggers when a new Tag is created.',

      webhook_subscribe: -> (webhook_url, _connection, _input, _recipe_id) {
        call('create_webhook', webhook_url, 'tag-created')
      },

      webhook_notification: -> (_input, payload, _extended_input_schema, _extended_output_schema, _headers, _params) {
        batch = payload['items'] or payload['Items']
        messages = batch.map { |item| item['data'] }.map { |index| index['messages'] }.flatten
        events = messages.map { |item| workato.parse_json(item['data']) }
        {
          "id" => messages.map { |message| message['id'] }.join('|'),
          "results" => events
        }
      },

      webhook_unsubscribe: -> (webhook_subscribe_output) {
        call('delete_webhook', webhook_subscribe_output['id'])
      },

      dedup: -> (webhook_notification_output) {
        webhook_notification_output['id']
      },

      output_fields: -> (_object_definitions) {
        [
          { name: 'results', type: 'array', of: 'object', properties: [
            { name: 'id' },
            { name: 'eventType' },
            { name: 'eventDate' },
            { name: 'user' },
            { name: 'properties', type: 'object', properties:
              [
                { name: 'source' },
                { name: 'tagId' },
              ]
            }
          ]
          }
        ]
      },

      sample_output: -> (_connection) {
        {
          :results => [
            {
              :properties => {
                :source => 'UI',
                :tagId => 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
              },
              :id => 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
              :eventType => 'tag-created',
              :user => 'user@getguru.com',
              :eventDate => '2021-05-17T16:50:40.391+0000'
            }
          ]
        }
      }
    },

    new_member: {
      title: 'New Member',
      subtitle: 'Triggers when a new member was invited to team',
      description: 'Triggers when a new member was invited to team',
      help: 'Triggers when a new member was invited to team.',

      webhook_subscribe: -> (webhook_url, _connection, _input, _recipe_id) {
        call('create_webhook', webhook_url, 'team-member-added')
      },

      webhook_notification: -> (_input, payload, _extended_input_schema, _extended_output_schema, _headers, _params) {
        batch = payload['items'] or payload['Items']
        messages = batch.map { |item| item['data'] }.map { |index| index['messages'] }.flatten
        events = messages.map { |item| workato.parse_json(item['data']) }
        {
          :id => messages.map { |message| message['id'] }.join('|'),
          :Results => events
        }
      },

      webhook_unsubscribe: -> (webhook_subscribe_output) {
        call('delete_webhook', webhook_subscribe_output[:id])
      },

      output_fields: -> (_object_definitions) {
        [
          {
            name: 'Results', type: :array, properties: [
            { name: 'id' },
            { name: 'eventType' },
            { name: 'eventDate', type: :date_time },
            { name: 'user' },
            {
              name: 'properties', type: :object, properties: [
              { name: 'source' },
              { name: 'memberId' }
            ]
            }
          ]
          }
        ]
      },

      dedup: -> (processed_message) {
        processed_message[:id]
      },

      sample_output: -> {
        {
          "id": "afc1a74c-cd2a-45ab-8b00-0e11c49188e6:0",
          "results": [
            {
              "id": "8407ca36-33a9-4db6-84d3-656c10eb9675",
              "eventType": "team-member-added",
              "eventDate": "2021-05-21T15:21:02.233+0000",
              "user": "test@test.com",
              "properties": {
                "source": "UI",
                "memberId": "added@test.com"
              }
            }
          ]
        }
      }
    },

    user_added_to_group: {
      title: 'New User Added to Group',
      subtitle: 'Triggers when a User is added to a Group',
      description: 'Triggers when a User is added to a Group',
      help: 'Triggers when a User is added to a Group.',

      webhook_subscribe: -> (webhook_url, _connection, _input, _recipe_id) {
        call('create_webhook', webhook_url, 'usergroup-member-added')
      },

      webhook_notification: -> (_input, payload, _extended_input_schema, _extended_output_schema, _headers, _params) {
        batch = payload['items'] or payload['Items']
        messages = batch.map { |item| item['data'] }.map { |index| index['messages'] }.flatten
        events = messages.map { |item| workato.parse_json(item['data']) }
        {
          "id" => messages.map { |message| message['id'] }.join('|'),
          "results" => events
        }
      },

      webhook_unsubscribe: -> (webhook_subscribe_output) {
        call('delete_webhook', webhook_subscribe_output['id'])
      },

      dedup: -> (webhook_notification_output) {
        webhook_notification_output['id']
      },

      output_fields: -> (_object_definitions) {
        [
          { name: 'results', type: 'array', of: 'object', properties: [
            { name: 'id' },
            { name: 'eventType' },
            { name: 'eventDate' },
            { name: 'user' },
            { name: 'properties', type: 'object', properties:
              [
                { name: 'source' },
                { name: 'memberId' },
                { name: 'userGroupId' },
              ]
            }
          ]
          }
        ]
      },

      sample_output: -> (_connection) {
        {
          :results => [
            {
              :properties => {
                :source => 'UI',
                :memberId => 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
                :userGroupId => 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
              },
              :id => 'cccccccc-cccc-cccc-cccc-cccccccccccc',
              :eventType => 'usergroup-member-added',
              :user => 'user@getguru.com',
              :eventDate => '2021-05-17T16:50:40.391+0000'
            }
          ]
        }
      }
    }
  },

  pick_lists: {
    boards: -> (_connection) {
      get('boards').map do |field|
        [field['title'], field['id']]
      end
    },

    boards_in_collection: -> (_connection, collectionId:) {
      response = get('boards/home').params(collection: collectionId)['items']

      boards_from_board_groups = response&.
        select { |object| object['type'] == 'section' }&.
        map { |board_group| board_group['items'] }&.flatten&.
        map { |board| [board['title'], board['id']] }

      boards_without_board_groups = response&.
        select { |object| object['type'] == 'board' }&.
        map { |board| [board['title'], board['id']] }

      boards_without_board_groups&.concat(boards_from_board_groups)
    },

    collections: -> (_connection) {
      get('collections').map do |field|
        [field['name'], field['id']]
      end
    },

    collections_user_can_author: -> (connection) {
      get("users/#{connection['username']}/collections")&.
        select { |o| o['roles'].include?('AUTHOR') or o['roles'].include?('COLL_ADMIN') }&.
        map { |object| object['collection'] }&.
        map { |collection| [collection['name'], collection['id']] }
    },

    collections_user_has_access: -> (connection) {
      get("users/#{connection['username']}/collections")&.
        map { |object| object['collection'] }&.
        map { |collection| [collection['name'], collection['id']] }
    },

    groups: -> (_connection) {
      get('groups').map do |field|
        [field['name'], field['id']]
      end
    },

    query_types: -> (_connection) {
      [
        %w[Cards cards],
        %w[Questions questions],
        %w[Archived archived],
        %w[Recovered recovered],
        %w[Legacy legacy]
      ]
    },

    sort_fields: -> (_connection) {
      [
        %w[Last\ modified\ date lastModified],
        %w[Date\ created dateCreated],
        %w[Last\ verified\ date lastVerified],
        %w[Next\ verification\ date nextVerificationDate]
      ]
    },

    share_status: -> (_connection) {
      [
        %w[Team TEAM],
        %w[Private PRIVATE],
        %w[Public PUBLIC]
      ]
    },

    tags: -> (_connection) {
      arr = []
      get("teams/myteam/tagcategories").map { |field|
        parsed_tag = field['tags'].map { |tag|
          [tag['value'], tag['id']]
        }
        arr.concat parsed_tag
      }
      arr
    },

    tag_categories: -> (_connection) {
      get("teams/myteam/tagcategories").map do |field|
        [field['name'], field['id']]
      end
    },

    verification_intervals: -> (_connection) {
      [
        ["Every Week", 7],
        ["Every 2 Weeks", 14],
        ["Every Month", 30],
        ["Every 3 Months", 90],
        ["Every 6 Months", 180],
        ["Every Year", 365]
      ]
    },

    verifiers: -> (_connection, collection_id:) {
      [] unless collection_id.present?

      get("cards/members/verify?collection=#{collection_id}").reject { |member|
        member.nil? or (member['type'] == 'user' and member['user']['status'] == 'PENDING')
      }.map { |member|
        if member['type'] == 'user-group'
          [member['userGroup']&.[]('name'), member['userGroup'].to_json]
        else
          user = member['user']
          ["#{user['firstName']} #{user['lastName']}", member['user'].to_json]
        end
      }
    }
  }
}