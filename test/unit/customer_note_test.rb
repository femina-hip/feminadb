require File.dirname(__FILE__) + '/../test_helper'

class CustomerNoteTest < Test::Unit::TestCase
  fixtures :customers, :customer_notes

  def test_crud
    new_note = CustomerNote.new(:customer_id => 1, :note => 'Hi, there!')
    assert new_note.save
    new_note_back = CustomerNote.find(new_note.id)
    assert_equal new_note, new_note_back
    new_note_back.note = new_note_back.note.reverse
    assert new_note_back.save
    assert new_note.destroy
  end

  def test_cannot_modify
    new_note = CustomerNote.new(:customer_id => 1, :note => 'Hello')
    assert new_note.save
    new_note_back = CustomerNote.find(new_note.id)
    new_note.note = 'Should not be saved'
    assert new_note.save!
    new_note_back2 = CustomerNote.find(new_note.id)
    assert_equal 'Hello', new_note_back2.note
  end
end
