require 'test_helper'
require 'json-schema'
require 'rdf/isomorphic'
require Rails.root.join('test/support/aip_helper')

class Aip::V1::ItemsControllerTest < ActionDispatch::IntegrationTest

  include AipHelper

  setup do
    @regular_user = users(:regular)
    @private_item = items(:private_item)
    @entity = Item.name.underscore.pluralize

    @public_item = create_entity(
      entity_class: Item,
      parameters: {
        visibility: JupiterCore::VISIBILITY_PUBLIC,
        owner_id: users(:admin).id,
        title: 'Item with files',
        creators: ['Joe Blow'],
        created: '1000000 BC',
        languages: [CONTROLLED_VOCABULARIES[:language].english],
        item_type: CONTROLLED_VOCABULARIES[:item_type].article,
        publication_status: [CONTROLLED_VOCABULARIES[:publication_status].published],
        license: CONTROLLED_VOCABULARIES[:license].attribution_4_0_international,
        subject: ['Items']
      },
      files: [
        file_fixture('image-sample.jpeg'),
        file_fixture('text-sample.txt')
      ]
    )
  end

  test 'should be able to show a visible item to admin' do
    sign_in_as_system_user
    get aip_v1_entity_url(
      id: @public_item,
      entity: @entity
    )
    assert_response :success
  end

  test 'should not be able to show a visible item to user' do
    sign_in_as @regular_user
    get aip_v1_entity_url(
      id: @public_item,
      entity: @entity
    )
    assert_response :redirect
  end

  test 'should not be able to show a private item to user' do
    sign_in_as @regular_user
    get aip_v1_entity_url(
      id: @public_item,
      entity: @entity
    )
    assert_response :redirect
  end

  test 'should get item metadata graph with n3 serialization for base example' do
    sign_in_as_system_user
    get aip_v1_entity_url(
      entity: @entity,
      id: items(:radioactive_item_base)
    )
    assert_response :success

    graph = generate_graph_from_n3(response.body)
    rendered_graph = generate_graph_from_n3(
      file_fixture('n3/e2ec88e3-3266-4e95-8575-8b04fac2a679-base.n3').read
    )

    assert_equal true, rendered_graph.isomorphic_with?(graph)
  end

  test 'should get item metadata graph with n3 serialization for embargo example' do
    sign_in_as_system_user
    get aip_v1_entity_url(
      entity: @entity,
      id: items(:radioactive_item_embargoed)
    )
    assert_response :success

    graph = generate_graph_from_n3(response.body)

    rendered_graph = generate_graph_from_n3(
      file_fixture('n3/3bb26070-0d25-4f0e-b44f-e9879da333ec-embargoed.n3').read
    )

    assert_equal true, rendered_graph.isomorphic_with?(graph)
  end

  test 'should get item metadata graph with n3 serialization for previously embargoed example' do
    sign_in_as_system_user
    get aip_v1_entity_url(
      entity: @entity,
      id: items(:radioactive_item_prev_embargoed)
    )
    assert_response :success

    graph = generate_graph_from_n3(response.body)

    rendered_graph = generate_graph_from_n3(
      file_fixture('n3/2107bfb6-2670-4ffc-94a1-aeb4f8c1fd81-prev-embargoed.n3').read
    )

    assert_equal true, rendered_graph.isomorphic_with?(graph)
  end

  test 'should get item metadata graph with n3 serialization for rights example' do
    sign_in_as_system_user
    get aip_v1_entity_url(
      entity: @entity,
      id: items(:radioactive_item_rights)
    )
    assert_response :success

    graph = generate_graph_from_n3(response.body)

    rendered_graph = generate_graph_from_n3(
      file_fixture('n3/c795337f-075f-429a-bb18-16b56d9b750f-rights.n3').read
    )

    assert_equal true, rendered_graph.isomorphic_with?(graph)
  end

  test 'should get item metadata graph with n3 serialization for published status example' do
    sign_in_as_system_user
    get aip_v1_entity_url(
      entity: @entity,
      id: items(:radioactive_item_published_status)
    )
    assert_response :success

    graph = generate_graph_from_n3(response.body)

    rendered_graph = generate_graph_from_n3(
      file_fixture('n3/93126aae-4b9d-4db2-98f1-4e04b40778cf-published-status.n3').read
    )

    assert_equal true, rendered_graph.isomorphic_with?(graph)
  end

  # Basic test checking if response has xml format.
  test 'should get item filesets order in xml format' do
    sign_in_as_system_user
    get aip_v1_entity_filesets_url(
      entity: @entity,
      id: @public_item
    )

    assert_response :success

    assert_equal true, check_file_order_xml(response.body)
  end

  test 'should get item file paths' do
    sign_in_as_system_user
    get aip_v1_entity_file_paths_url(
      entity: @entity,
      id: @public_item
    )
    assert_response :success
    json_string = response.body
    assert_equal true, JSON::Validator.validate(
      file_paths_json_schema,
      json_string
    )
    json_response = JSON.parse(json_string)

    # Check that all files actually exist
    json_response['files'].map do |file_path|
      assert_equal true, File.file?(file_path['file_path'])
    end
  end

  # Basic tests checking if response has n3 serialization.
  # This should be changed to verify the response content is correct.

  test 'should get item file set metadata graph with n3 serialization' do
    sign_in_as_system_user
    get aip_v1_entity_file_set_url(
      entity: @entity,
      id: @public_item,
      file_set_id: @public_item.files.first.fileset_uuid
    )
    assert_response :success

    graph = generate_graph_from_n3(response.body)
    assert_equal true, graph.graph?
  end

  test 'should get item fixity metadata graph with n3 serialization' do
    sign_in_as_system_user
    url = aip_v1_entity_fileset_fixity_url(
      entity: @entity,
      id: @public_item,
      file_set_id: @public_item.files.first.fileset_uuid
    )

    graph = get_n3_graph(url)
    assert_response :success
    assert_equal true, graph.graph?
  end

  test 'should get item original file metadata graph with n3 serialization' do
    sign_in_as_system_user
    url = aip_v1_entity_fileset_original_file_url(
      entity: @entity,
      id: @public_item,
      file_set_id: @public_item.files.first.fileset_uuid
    )

    graph = get_n3_graph(url)
    assert_response :success
    assert_equal true, graph.graph?
  end

end
