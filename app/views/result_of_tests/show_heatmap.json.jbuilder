scale = 0.8

json.testing do
  json.partial! 'tests/testing_data.json.jbuilder',
    test: @test,
    question: @question,
    previous_question: nil,
    description: @description,
    image: @image,
    client: @client,
    mode: 'heatmap'
end
json.screen_height @heatmap.screen_height
json.screen_width @heatmap.screen_width
json.heatmap_data @heatmap.scale_heatmap(scale_ratio: scale)
json.scale scale
json.heatmap_url client_heatmap_path(params[:client_id], params[:result_id])
json.number @question.number
json.question_count @result.question_results.count
