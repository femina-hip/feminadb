class CustomerNoteObserver < ActiveRecord::Observer
  def after_create(note)
    note.index
    maybe_add_tag note
  end

  def after_destroy(note)
    note.index
    maybe_remove_tag note
  end

  private
    # Returns a Tag from the given Note, or nil if there is no such Tag.
    # If may_create is true, the Tag will be created if it does not exist.
    def tag_from_note(note, may_create)
      if note.note =~ /^TAG_([A-Z0-9][_A-Z0-9]+)$/
        if may_create
          Tag.find_or_initialize_by_name($1)
        else
          Tag.find_by_name($1)
        end
      end
    end

    # Increments or creates a new Tag if the Note passed is a tagging Note
    def maybe_add_tag(note)
      if tag = tag_from_note(note, true)
        tag.num_customers += 1
        tag.save!
      end
    end

    # Decrements or destroys a Tag if the Note passed is a tagging Note
    def maybe_remove_tag(note)
      if tag = tag_from_note(note, false)
        tag.num_customers -= 1
        if tag.num_customers == 0
          tag.destroy
        else
          tag.save!
        end
      end
    end
end
