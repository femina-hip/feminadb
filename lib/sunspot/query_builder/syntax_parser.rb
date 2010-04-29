# Autogenerated from a Treetop grammar. Edits may be lost.


module Sunspot
  module QueryBuilder
    module Syntax
      include Treetop::Runtime

      def root
        @root ||= :expression
      end

      module Expression0
        def maybe_space1
          elements[0]
        end

        def maybe_space2
          elements[2]
        end
      end

      module Expression1
        def type; :expression; end
  
        def subnodes
          elements[1].terminal? ? [] : [elements[1]]
        end
      end

      def _nt_expression
        start_index = index
        if node_cache[:expression].has_key?(index)
          cached = node_cache[:expression][index]
          if cached
            cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
            @index = cached.interval.end
          end
          return cached
        end

        i0, s0 = index, []
        r1 = _nt_maybe_space
        s0 << r1
        if r1
          r3 = _nt_disjunction
          if r3
            r2 = r3
          else
            r2 = instantiate_node(SyntaxNode,input, index...index)
          end
          s0 << r2
          if r2
            r4 = _nt_maybe_space
            s0 << r4
          end
        end
        if s0.last
          r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
          r0.extend(Expression0)
          r0.extend(Expression1)
        else
          @index = i0
          r0 = nil
        end

        node_cache[:expression][start_index] = r0

        r0
      end

      module Disjunction0
        def space1
          elements[0]
        end

        def or_rule
          elements[1]
        end

        def space2
          elements[2]
        end

        def expression
          elements[3]
        end
      end

      module Disjunction1
        def conjunction
          elements[0]
        end

      end

      module Disjunction2
        def type; :disjunction; end
  
        def expressions
          elements[1].terminal? ? [] : [elements[1].expression]
        end
  
        def subnodes
          [conjunction] + expressions
        end
      end

      def _nt_disjunction
        start_index = index
        if node_cache[:disjunction].has_key?(index)
          cached = node_cache[:disjunction][index]
          if cached
            cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
            @index = cached.interval.end
          end
          return cached
        end

        i0, s0 = index, []
        r1 = _nt_conjunction
        s0 << r1
        if r1
          i3, s3 = index, []
          r4 = _nt_space
          s3 << r4
          if r4
            r5 = _nt_or_rule
            s3 << r5
            if r5
              r6 = _nt_space
              s3 << r6
              if r6
                r7 = _nt_expression
                s3 << r7
              end
            end
          end
          if s3.last
            r3 = instantiate_node(SyntaxNode,input, i3...index, s3)
            r3.extend(Disjunction0)
          else
            @index = i3
            r3 = nil
          end
          if r3
            r2 = r3
          else
            r2 = instantiate_node(SyntaxNode,input, index...index)
          end
          s0 << r2
        end
        if s0.last
          r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
          r0.extend(Disjunction1)
          r0.extend(Disjunction2)
        else
          @index = i0
          r0 = nil
        end

        node_cache[:disjunction][start_index] = r0

        r0
      end

      module Conjunction0
        def and_rule
          elements[0]
        end

        def space
          elements[1]
        end
      end

      module Conjunction1
        def space
          elements[0]
        end

        def expression
          elements[3]
        end
      end

      module Conjunction2
        def factor
          elements[0]
        end

      end

      module Conjunction3
        def type; :conjunction; end
  
        def expressions
          elements[1].terminal? ? [] : [elements[1].expression]
        end
  
        def subnodes
          [factor] + expressions
        end
      end

      def _nt_conjunction
        start_index = index
        if node_cache[:conjunction].has_key?(index)
          cached = node_cache[:conjunction][index]
          if cached
            cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
            @index = cached.interval.end
          end
          return cached
        end

        i0, s0 = index, []
        r1 = _nt_factor
        s0 << r1
        if r1
          i3, s3 = index, []
          r4 = _nt_space
          s3 << r4
          if r4
            i5 = index
            r6 = _nt_or_rule
            if r6
              r5 = nil
            else
              @index = i5
              r5 = instantiate_node(SyntaxNode,input, index...index)
            end
            s3 << r5
            if r5
              i8, s8 = index, []
              r9 = _nt_and_rule
              s8 << r9
              if r9
                r10 = _nt_space
                s8 << r10
              end
              if s8.last
                r8 = instantiate_node(SyntaxNode,input, i8...index, s8)
                r8.extend(Conjunction0)
              else
                @index = i8
                r8 = nil
              end
              if r8
                r7 = r8
              else
                r7 = instantiate_node(SyntaxNode,input, index...index)
              end
              s3 << r7
              if r7
                r11 = _nt_expression
                s3 << r11
              end
            end
          end
          if s3.last
            r3 = instantiate_node(SyntaxNode,input, i3...index, s3)
            r3.extend(Conjunction1)
          else
            @index = i3
            r3 = nil
          end
          if r3
            r2 = r3
          else
            r2 = instantiate_node(SyntaxNode,input, index...index)
          end
          s0 << r2
        end
        if s0.last
          r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
          r0.extend(Conjunction2)
          r0.extend(Conjunction3)
        else
          @index = i0
          r0 = nil
        end

        node_cache[:conjunction][start_index] = r0

        r0
      end

      module Factor0
        def test
          elements[1]
        end
      end

      module Factor1
        def type; :factor; end
  
        def not?
          !elements[0].text_value.empty?
        end
  
        def subnodes
          [test]
        end
      end

      def _nt_factor
        start_index = index
        if node_cache[:factor].has_key?(index)
          cached = node_cache[:factor][index]
          if cached
            cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
            @index = cached.interval.end
          end
          return cached
        end

        i0, s0 = index, []
        r2 = _nt_not
        if r2
          r1 = r2
        else
          r1 = instantiate_node(SyntaxNode,input, index...index)
        end
        s0 << r1
        if r1
          r3 = _nt_test
          s0 << r3
        end
        if s0.last
          r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
          r0.extend(Factor0)
          r0.extend(Factor1)
        else
          @index = i0
          r0 = nil
        end

        node_cache[:factor][start_index] = r0

        r0
      end

      module Test0
        def expression
          elements[1]
        end

      end

      module Test1
        def type; :test; end
        def needs_parentheses?; true; end
        def subnodes; [expression]; end
      end

      module Test2
        def filter
          elements[1]
        end
      end

      module Test3
        def type; :test; end
        def needs_parentheses?; false; end
        def subnodes; [filter]; end
      end

      def _nt_test
        start_index = index
        if node_cache[:test].has_key?(index)
          cached = node_cache[:test][index]
          if cached
            cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
            @index = cached.interval.end
          end
          return cached
        end

        i0 = index
        i1, s1 = index, []
        if has_terminal?('(', false, index)
          r2 = instantiate_node(SyntaxNode,input, index...(index + 1))
          @index += 1
        else
          terminal_parse_failure('(')
          r2 = nil
        end
        s1 << r2
        if r2
          r3 = _nt_expression
          s1 << r3
          if r3
            if has_terminal?(')', false, index)
              r4 = instantiate_node(SyntaxNode,input, index...(index + 1))
              @index += 1
            else
              terminal_parse_failure(')')
              r4 = nil
            end
            s1 << r4
          end
        end
        if s1.last
          r1 = instantiate_node(SyntaxNode,input, i1...index, s1)
          r1.extend(Test0)
          r1.extend(Test1)
        else
          @index = i1
          r1 = nil
        end
        if r1
          r0 = r1
        else
          i5, s5 = index, []
          if has_terminal?('', false, index)
            r6 = instantiate_node(SyntaxNode,input, index...(index + 0))
            @index += 0
          else
            terminal_parse_failure('')
            r6 = nil
          end
          s5 << r6
          if r6
            r7 = _nt_filter
            s5 << r7
          end
          if s5.last
            r5 = instantiate_node(SyntaxNode,input, i5...index, s5)
            r5.extend(Test2)
            r5.extend(Test3)
          else
            @index = i5
            r5 = nil
          end
          if r5
            r0 = r5
          else
            @index = i0
            r0 = nil
          end
        end

        node_cache[:test][start_index] = r0

        r0
      end

      module Filter0
        def dynamic_field
          elements[0]
        end

        def comparator
          elements[1]
        end

        def value
          elements[2]
        end
      end

      module Filter1
        def type; :filter; end
        def subnodes
          [dynamic_field, comparator, value]
        end
      end

      module Filter2
        def field
          elements[0]
        end

        def comparator
          elements[1]
        end

        def value
          elements[2]
        end
      end

      module Filter3
        def type; :filter; end
        def subnodes
          [field, comparator, value]
        end
      end

      module Filter4
        def value
          elements[1]
        end
      end

      module Filter5
        def type; :filter; end
        def subnodes; [value]; end
      end

      def _nt_filter
        start_index = index
        if node_cache[:filter].has_key?(index)
          cached = node_cache[:filter][index]
          if cached
            cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
            @index = cached.interval.end
          end
          return cached
        end

        i0 = index
        i1, s1 = index, []
        r2 = _nt_dynamic_field
        s1 << r2
        if r2
          r3 = _nt_comparator
          s1 << r3
          if r3
            r4 = _nt_value
            s1 << r4
          end
        end
        if s1.last
          r1 = instantiate_node(SyntaxNode,input, i1...index, s1)
          r1.extend(Filter0)
          r1.extend(Filter1)
        else
          @index = i1
          r1 = nil
        end
        if r1
          r0 = r1
        else
          i5, s5 = index, []
          r6 = _nt_field
          s5 << r6
          if r6
            r7 = _nt_comparator
            s5 << r7
            if r7
              r8 = _nt_value
              s5 << r8
            end
          end
          if s5.last
            r5 = instantiate_node(SyntaxNode,input, i5...index, s5)
            r5.extend(Filter2)
            r5.extend(Filter3)
          else
            @index = i5
            r5 = nil
          end
          if r5
            r0 = r5
          else
            i9, s9 = index, []
            if has_terminal?('', false, index)
              r10 = instantiate_node(SyntaxNode,input, index...(index + 0))
              @index += 0
            else
              terminal_parse_failure('')
              r10 = nil
            end
            s9 << r10
            if r10
              r11 = _nt_value
              s9 << r11
            end
            if s9.last
              r9 = instantiate_node(SyntaxNode,input, i9...index, s9)
              r9.extend(Filter4)
              r9.extend(Filter5)
            else
              @index = i9
              r9 = nil
            end
            if r9
              r0 = r9
            else
              @index = i0
              r0 = nil
            end
          end
        end

        node_cache[:filter][start_index] = r0

        r0
      end

      module Field0
      end

      module Field1
        def type; :field; end
      end

      def _nt_field
        start_index = index
        if node_cache[:field].has_key?(index)
          cached = node_cache[:field][index]
          if cached
            cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
            @index = cached.interval.end
          end
          return cached
        end

        i0, s0 = index, []
        if has_terminal?('\G[a-zA-Z]', true, index)
          r1 = true
          @index += 1
        else
          r1 = nil
        end
        s0 << r1
        if r1
          s2, i2 = [], index
          loop do
            if has_terminal?('\G[a-zA-Z0-9_]', true, index)
              r3 = true
              @index += 1
            else
              r3 = nil
            end
            if r3
              s2 << r3
            else
              break
            end
          end
          r2 = instantiate_node(SyntaxNode,input, i2...index, s2)
          s0 << r2
        end
        if s0.last
          r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
          r0.extend(Field0)
          r0.extend(Field1)
        else
          @index = i0
          r0 = nil
        end

        node_cache[:field][start_index] = r0

        r0
      end

      module DynamicField0
        def field1
          elements[0]
        end

        def field2
          elements[2]
        end
      end

      module DynamicField1
        def type; :dynamic_field; end
        def subnodes; [ field1, field2 ]; end
      end

      def _nt_dynamic_field
        start_index = index
        if node_cache[:dynamic_field].has_key?(index)
          cached = node_cache[:dynamic_field][index]
          if cached
            cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
            @index = cached.interval.end
          end
          return cached
        end

        i0, s0 = index, []
        r1 = _nt_field
        s0 << r1
        if r1
          if has_terminal?(':', false, index)
            r2 = instantiate_node(SyntaxNode,input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure(':')
            r2 = nil
          end
          s0 << r2
          if r2
            r3 = _nt_field
            s0 << r3
          end
        end
        if s0.last
          r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
          r0.extend(DynamicField0)
          r0.extend(DynamicField1)
        else
          @index = i0
          r0 = nil
        end

        node_cache[:dynamic_field][start_index] = r0

        r0
      end

      module Comparator0
        def type; :comparator; end
      end

      def _nt_comparator
        start_index = index
        if node_cache[:comparator].has_key?(index)
          cached = node_cache[:comparator][index]
          if cached
            cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
            @index = cached.interval.end
          end
          return cached
        end

        i0 = index
        if has_terminal?(':', false, index)
          r1 = instantiate_node(SyntaxNode,input, index...(index + 1))
          @index += 1
        else
          terminal_parse_failure(':')
          r1 = nil
        end
        if r1
          r0 = r1
          r0.extend(Comparator0)
        else
          if has_terminal?('>=', false, index)
            r2 = instantiate_node(SyntaxNode,input, index...(index + 2))
            @index += 2
          else
            terminal_parse_failure('>=')
            r2 = nil
          end
          if r2
            r0 = r2
            r0.extend(Comparator0)
          else
            if has_terminal?('<=', false, index)
              r3 = instantiate_node(SyntaxNode,input, index...(index + 2))
              @index += 2
            else
              terminal_parse_failure('<=')
              r3 = nil
            end
            if r3
              r0 = r3
              r0.extend(Comparator0)
            else
              if has_terminal?('=', false, index)
                r4 = instantiate_node(SyntaxNode,input, index...(index + 1))
                @index += 1
              else
                terminal_parse_failure('=')
                r4 = nil
              end
              if r4
                r0 = r4
                r0.extend(Comparator0)
              else
                if has_terminal?('<', false, index)
                  r5 = instantiate_node(SyntaxNode,input, index...(index + 1))
                  @index += 1
                else
                  terminal_parse_failure('<')
                  r5 = nil
                end
                if r5
                  r0 = r5
                  r0.extend(Comparator0)
                else
                  if has_terminal?('>', false, index)
                    r6 = instantiate_node(SyntaxNode,input, index...(index + 1))
                    @index += 1
                  else
                    terminal_parse_failure('>')
                    r6 = nil
                  end
                  if r6
                    r0 = r6
                    r0.extend(Comparator0)
                  else
                    @index = i0
                    r0 = nil
                  end
                end
              end
            end
          end
        end

        node_cache[:comparator][start_index] = r0

        r0
      end

      module Value0
      end

      module Value1
      end

      module Value2
      end

      module Value3
      end

      module Value4
      end

      module Value5
        def type; :value; end
        def value
          if text_value[0] == ?' || text_value[0] == ?"
            text_value[1..-2]
          else
            text_value
          end
        end
      end

      def _nt_value
        start_index = index
        if node_cache[:value].has_key?(index)
          cached = node_cache[:value][index]
          if cached
            cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
            @index = cached.interval.end
          end
          return cached
        end

        i0 = index
        i1, s1 = index, []
        if has_terminal?('"', false, index)
          r2 = instantiate_node(SyntaxNode,input, index...(index + 1))
          @index += 1
        else
          terminal_parse_failure('"')
          r2 = nil
        end
        s1 << r2
        if r2
          s3, i3 = [], index
          loop do
            i4, s4 = index, []
            i5 = index
            if has_terminal?('\G["]', true, index)
              r6 = true
              @index += 1
            else
              r6 = nil
            end
            if r6
              r5 = nil
            else
              @index = i5
              r5 = instantiate_node(SyntaxNode,input, index...index)
            end
            s4 << r5
            if r5
              if index < input_length
                r7 = instantiate_node(SyntaxNode,input, index...(index + 1))
                @index += 1
              else
                terminal_parse_failure("any character")
                r7 = nil
              end
              s4 << r7
            end
            if s4.last
              r4 = instantiate_node(SyntaxNode,input, i4...index, s4)
              r4.extend(Value0)
            else
              @index = i4
              r4 = nil
            end
            if r4
              s3 << r4
            else
              break
            end
          end
          r3 = instantiate_node(SyntaxNode,input, i3...index, s3)
          s1 << r3
          if r3
            if has_terminal?('"', false, index)
              r8 = instantiate_node(SyntaxNode,input, index...(index + 1))
              @index += 1
            else
              terminal_parse_failure('"')
              r8 = nil
            end
            s1 << r8
          end
        end
        if s1.last
          r1 = instantiate_node(SyntaxNode,input, i1...index, s1)
          r1.extend(Value1)
        else
          @index = i1
          r1 = nil
        end
        if r1
          r0 = r1
          r0.extend(Value5)
        else
          i9, s9 = index, []
          if has_terminal?("'", false, index)
            r10 = instantiate_node(SyntaxNode,input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure("'")
            r10 = nil
          end
          s9 << r10
          if r10
            s11, i11 = [], index
            loop do
              i12, s12 = index, []
              i13 = index
              if has_terminal?('\G[\']', true, index)
                r14 = true
                @index += 1
              else
                r14 = nil
              end
              if r14
                r13 = nil
              else
                @index = i13
                r13 = instantiate_node(SyntaxNode,input, index...index)
              end
              s12 << r13
              if r13
                if index < input_length
                  r15 = instantiate_node(SyntaxNode,input, index...(index + 1))
                  @index += 1
                else
                  terminal_parse_failure("any character")
                  r15 = nil
                end
                s12 << r15
              end
              if s12.last
                r12 = instantiate_node(SyntaxNode,input, i12...index, s12)
                r12.extend(Value2)
              else
                @index = i12
                r12 = nil
              end
              if r12
                s11 << r12
              else
                break
              end
            end
            r11 = instantiate_node(SyntaxNode,input, i11...index, s11)
            s9 << r11
            if r11
              if has_terminal?("'", false, index)
                r16 = instantiate_node(SyntaxNode,input, index...(index + 1))
                @index += 1
              else
                terminal_parse_failure("'")
                r16 = nil
              end
              s9 << r16
            end
          end
          if s9.last
            r9 = instantiate_node(SyntaxNode,input, i9...index, s9)
            r9.extend(Value3)
          else
            @index = i9
            r9 = nil
          end
          if r9
            r0 = r9
            r0.extend(Value5)
          else
            s17, i17 = [], index
            loop do
              i18, s18 = index, []
              i19 = index
              if has_terminal?('\G[ \'"()]', true, index)
                r20 = true
                @index += 1
              else
                r20 = nil
              end
              if r20
                r19 = nil
              else
                @index = i19
                r19 = instantiate_node(SyntaxNode,input, index...index)
              end
              s18 << r19
              if r19
                if index < input_length
                  r21 = instantiate_node(SyntaxNode,input, index...(index + 1))
                  @index += 1
                else
                  terminal_parse_failure("any character")
                  r21 = nil
                end
                s18 << r21
              end
              if s18.last
                r18 = instantiate_node(SyntaxNode,input, i18...index, s18)
                r18.extend(Value4)
              else
                @index = i18
                r18 = nil
              end
              if r18
                s17 << r18
              else
                break
              end
            end
            if s17.empty?
              @index = i17
              r17 = nil
            else
              r17 = instantiate_node(SyntaxNode,input, i17...index, s17)
            end
            if r17
              r0 = r17
              r0.extend(Value5)
            else
              @index = i0
              r0 = nil
            end
          end
        end

        node_cache[:value][start_index] = r0

        r0
      end

      def _nt_or_rule
        start_index = index
        if node_cache[:or_rule].has_key?(index)
          cached = node_cache[:or_rule][index]
          if cached
            cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
            @index = cached.interval.end
          end
          return cached
        end

        i0 = index
        if has_terminal?('OR', false, index)
          r1 = instantiate_node(SyntaxNode,input, index...(index + 2))
          @index += 2
        else
          terminal_parse_failure('OR')
          r1 = nil
        end
        if r1
          r0 = r1
        else
          if has_terminal?('or', false, index)
            r2 = instantiate_node(SyntaxNode,input, index...(index + 2))
            @index += 2
          else
            terminal_parse_failure('or')
            r2 = nil
          end
          if r2
            r0 = r2
          else
            if has_terminal?('||', false, index)
              r3 = instantiate_node(SyntaxNode,input, index...(index + 2))
              @index += 2
            else
              terminal_parse_failure('||')
              r3 = nil
            end
            if r3
              r0 = r3
            else
              if has_terminal?('|', false, index)
                r4 = instantiate_node(SyntaxNode,input, index...(index + 1))
                @index += 1
              else
                terminal_parse_failure('|')
                r4 = nil
              end
              if r4
                r0 = r4
              else
                @index = i0
                r0 = nil
              end
            end
          end
        end

        node_cache[:or_rule][start_index] = r0

        r0
      end

      def _nt_and_rule
        start_index = index
        if node_cache[:and_rule].has_key?(index)
          cached = node_cache[:and_rule][index]
          if cached
            cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
            @index = cached.interval.end
          end
          return cached
        end

        i0 = index
        if has_terminal?('AND', false, index)
          r1 = instantiate_node(SyntaxNode,input, index...(index + 3))
          @index += 3
        else
          terminal_parse_failure('AND')
          r1 = nil
        end
        if r1
          r0 = r1
        else
          if has_terminal?('and', false, index)
            r2 = instantiate_node(SyntaxNode,input, index...(index + 3))
            @index += 3
          else
            terminal_parse_failure('and')
            r2 = nil
          end
          if r2
            r0 = r2
          else
            if has_terminal?('&&', false, index)
              r3 = instantiate_node(SyntaxNode,input, index...(index + 2))
              @index += 2
            else
              terminal_parse_failure('&&')
              r3 = nil
            end
            if r3
              r0 = r3
            else
              if has_terminal?('&', false, index)
                r4 = instantiate_node(SyntaxNode,input, index...(index + 1))
                @index += 1
              else
                terminal_parse_failure('&')
                r4 = nil
              end
              if r4
                r0 = r4
              else
                @index = i0
                r0 = nil
              end
            end
          end
        end

        node_cache[:and_rule][start_index] = r0

        r0
      end

      module Not0
        def space
          elements[1]
        end
      end

      def _nt_not
        start_index = index
        if node_cache[:not].has_key?(index)
          cached = node_cache[:not][index]
          if cached
            cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
            @index = cached.interval.end
          end
          return cached
        end

        i0 = index
        if has_terminal?('-', false, index)
          r1 = instantiate_node(SyntaxNode,input, index...(index + 1))
          @index += 1
        else
          terminal_parse_failure('-')
          r1 = nil
        end
        if r1
          r0 = r1
        else
          if has_terminal?('!', false, index)
            r2 = instantiate_node(SyntaxNode,input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure('!')
            r2 = nil
          end
          if r2
            r0 = r2
          else
            i3, s3 = index, []
            if has_terminal?('NOT', false, index)
              r4 = instantiate_node(SyntaxNode,input, index...(index + 3))
              @index += 3
            else
              terminal_parse_failure('NOT')
              r4 = nil
            end
            s3 << r4
            if r4
              r5 = _nt_space
              s3 << r5
            end
            if s3.last
              r3 = instantiate_node(SyntaxNode,input, i3...index, s3)
              r3.extend(Not0)
            else
              @index = i3
              r3 = nil
            end
            if r3
              r0 = r3
            else
              @index = i0
              r0 = nil
            end
          end
        end

        node_cache[:not][start_index] = r0

        r0
      end

      def _nt_maybe_space
        start_index = index
        if node_cache[:maybe_space].has_key?(index)
          cached = node_cache[:maybe_space][index]
          if cached
            cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
            @index = cached.interval.end
          end
          return cached
        end

        s0, i0 = [], index
        loop do
          if has_terminal?(' ', false, index)
            r1 = instantiate_node(SyntaxNode,input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure(' ')
            r1 = nil
          end
          if r1
            s0 << r1
          else
            break
          end
        end
        r0 = instantiate_node(SyntaxNode,input, i0...index, s0)

        node_cache[:maybe_space][start_index] = r0

        r0
      end

      def _nt_space
        start_index = index
        if node_cache[:space].has_key?(index)
          cached = node_cache[:space][index]
          if cached
            cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
            @index = cached.interval.end
          end
          return cached
        end

        s0, i0 = [], index
        loop do
          if has_terminal?(' ', false, index)
            r1 = instantiate_node(SyntaxNode,input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure(' ')
            r1 = nil
          end
          if r1
            s0 << r1
          else
            break
          end
        end
        if s0.empty?
          @index = i0
          r0 = nil
        else
          r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
        end

        node_cache[:space][start_index] = r0

        r0
      end

    end

    class SyntaxParser < Treetop::Runtime::CompiledParser
      include Syntax
    end

  end
end