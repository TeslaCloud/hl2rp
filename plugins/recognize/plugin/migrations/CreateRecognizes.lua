ActiveRecord.define_model('recognizes', function(t)
  t:integer 'character_id'
  t:integer 'target_id'
  t:string  'name'
end)
