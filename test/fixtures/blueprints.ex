defmodule Fixtures.Blueprints do
  import Fixtures.Helpers
  use Fixtures.Helpers.Blueprints

  blueprint(:simple_test) do
    %{
      variables: %{
        aint: %{
          type: :integer,
          mapping: :in_required,
          default: quote(do: now())
        },
        bint: %{type: :integer, mapping: :inout_required, default: 0},
        cint: %{type: :integer, mapping: :inout_required, default: 0}
      },
      deductions: [
        %{
          branches: [
            %{
              conditions: [
                %{expression: quote(do: gt(@aint, 75))},
                %{expression: quote(do: lt(@aint, 200))}
              ],
              assignments: [
                %{target: :aint, expression: 72},
                %{target: :bint, expression: quote(do: add(1, @aint))},
                %{target: :cint, expression: quote(do: add(2, @bint))}
              ]
            }
          ]
        },
        %{
          branches: [
            %{
              conditions: [
                %{expression: quote(do: gt(@aint, 200))}
              ],
              assignments: [
                %{target: :cint, expression: quote(do: add(@aint, 1))}
              ]
            }
          ]
        }
      ]
    }
  end

  blueprint(:sig_test) do
    %{
      variables: %{
        age: %{type: :integer, mapping: :in_optional, default: 0},
        days: %{type: :integer, mapping: :in_optional},
        date: %{type: :date, mapping: :inout_optional}
      },
      deductions: [
        %{
          branches: [
            %{
              conditions: [
                %{
                  expression:
                    {:gt, [signature: {[:integer, :integer], :boolean}],
                     [
                       {:var, [signature: {[:name], :integer}], ["age"]},
                       12
                     ]}
                }
              ],
              assignments: [
                %{
                  target: :date,
                  expression: quote(do: add_days(@date, @days))
                }
              ]
            }
          ]
        }
      ]
    }
  end

  blueprint(:nested_test) do
    %{
      variables: %{
        enum_string: %{
          type: "string",
          mapping: :in_required,
          enum: ["v1", "v2"]
        },
        obj_list: %{
          type: "map[]",
          mapping: :in_required,
          children: %{
            child_int: %{type: :integer, mapping: :in_required},
            child_object: %{
              type: :map,
              mapping: :in_required,
              children: %{
                grand_child_int: %{type: :integer, mapping: :in_required}
              }
            }
          }
        },
        int_list: %{
          type: "integer[]",
          mapping: :inout_required
        },
        dnest: %{
          type: "map",
          mapping: :out,
          children: %{
            dnest2: %{
              type: "map[]",
              mapping: :out,
              children: %{
                dnest3: %{type: :string, mapping: :out}
              }
            }
          }
        },
        map_list: %{
          type: "map[]",
          mapping: :out,
          children: %{
            child_string: %{type: :string, mapping: :out},
            child_int: %{type: :integer, mapping: :out},
            child_object: %{
              type: :map,
              mapping: :out,
              children: %{
                grand_child_int: %{type: :integer, mapping: :out},
                grand_child_map: %{
                  type: :map,
                  mapping: :out,
                  children: %{
                    grand_grand_child_ints: %{type: "integer[]", mapping: :out}
                  }
                }
              }
            }
          }
        }
      },
      deductions: [
        %{
          branches: [
            %{
              conditions: [
                %{expression: quote(do: eq(@enum_string, "v1"))},
                %{
                  expression:
                    quote(
                      do:
                        eq(
                          var([:obj_list, 0, :child_object, :grand_child_int]),
                          98
                        )
                    )
                }
              ],
              assignments: [
                %{
                  target: [
                    :map_list,
                    1,
                    :child_object,
                    :grand_child_map,
                    :grand_grand_child_ints
                  ],
                  expression: [1, 2, 3],
                  description: "Keep this in logic"
                },
                %{
                  target: [
                    :map_list,
                    1,
                    :child_object,
                    :grand_child_map,
                    :grand_grand_child_ints,
                    8
                  ],
                  expression: 42
                },
                %{target: [:int_list, 2], expression: 54},
                %{
                  target: [:dnest, :dnest2, 4, :dnest3],
                  expression: "nested"
                },
                %{target: [:map_list, 4, :child_int], expression: 45},
                %{
                  target: [:map_list, 1, :child_object, :grand_child_int],
                  expression: 15
                }
              ]
            }
          ]
        },
        %{
          branches: [
            %{
              conditions: [],
              assignments: [
                %{target: [:map_list, 2, :child_int], expression: 25},
                %{
                  target: [:map_list, 3, :child_object, :grand_child_int],
                  expression: 35
                }
              ]
            }
          ]
        },
        %{
          branches: [
            %{
              conditions: [
                %{
                  expression:
                    {:gt, [signature: {[:integer, :integer], :boolean}],
                     [
                       {:var, [signature: {[:name], :integer}],
                        [[:int_list, 2]]},
                       32
                     ]}
                }
              ],
              assignments: [
                %{target: :enum_string, expression: "v1"},
                %{target: :int_list, expression: [1, 2, 3]}
              ]
            }
          ]
        }
      ]
    }
  end

  blueprint(:map_test) do
    %{
      variables: %{
        list: %{
          type: "map[]",
          mapping: :inout_required,
          children: %{
            name: %{type: :string, mapping: :in_required},
            nested: %{
              type: "map[]",
              mapping: :inout_required,
              children: %{
                nested: %{type: "integer[]", mapping: :inout_required}
              }
            }
          }
        },
        int: %{
          type: "integer",
          mapping: :in_required
        },
        str: %{
          type: "string",
          mapping: :in_required
        },
        num: %{
          type: "number",
          mapping: :in_required
        },
        ignore: %{
          type: "string",
          mapping: :out
        },
        map: %{
          type: :map,
          mapping: :in_required,
          children: %{
            nlist: %{type: "integer[]", mapping: :in_required},
            nmap: %{
              type: :map,
              mapping: :in_required,
              children: %{
                name: %{type: :string, mapping: :in_required}
              }
            },
            nlist2: %{
              type: "map[]",
              mapping: :in_required,
              children: %{
                nested: %{type: :integer, mapping: :in_required}
              }
            }
          }
        }
      }
    }
  end

  blueprint(:hash0_test) do
    %{
      variables: [
        %{name: :aint, type: :integer, mapping: :in_required, default: 0}
      ]
    }
  end

  blueprint(:hash1_test) do
    %{
      name: :hash1_test,
      variables: [
        %{name: :aint, type: :integer, mapping: :in_required, default: 0},
        %{name: :bint, type: :integer, mapping: :none, default: 0}
      ]
    }
  end

  blueprint(:hash2_test) do
    %{
      variables: [
        %{name: :bint, type: :integer, mapping: :none, default: 0},
        %{name: :aint, type: :integer, mapping: :in_required, default: 0}
      ]
    }
  end

  blueprint(:hash3_test) do
    %{
      variables: [
        %{name: :bint, type: :integer, mapping: :in_required, default: 0},
        %{name: :aint, type: :integer, mapping: :in_required, default: 0}
      ]
    }
  end

  blueprint(:nil_test) do
    %{
      variables: [
        %{name: :a0, type: :boolean, mapping: :in_optional},
        %{name: :b0, type: :integer, mapping: :out}
      ],
      deductions: [
        %{
          branches: [
            %{
              conditions: [
                %{expression: quote(do: is_false(@a0))}
              ],
              assignments: [
                %{target: :b0, expression: 20}
              ]
            },
            %{
              conditions: [],
              assignments: [
                %{target: :b0, expression: 10}
              ]
            }
          ]
        }
      ]
    }
  end

  blueprint(:nil_default_test) do
    %{
      variables: [
        %{name: :a0, type: :string, mapping: :in_optional},
        %{name: :b0, type: :integer, mapping: :out}
      ],
      deductions: [
        %{
          branches: [
            %{
              conditions: [
                %{expression: quote(do: neq(@a0, "hello"))}
              ],
              assignments: [
                %{target: :b0, expression: 20}
              ]
            },
            %{
              conditions: [],
              assignments: [
                %{target: :b0, expression: 10}
              ]
            }
          ]
        }
      ]
    }
  end

  blueprint(:empty_test) do
    %{
      variables: [],
      deductions: []
    }
  end

  blueprint(:rename_test) do
    %{
      variables: [
        %{name: :a0, type: :boolean, mapping: :inout_required},
        %{name: :b0, type: :boolean, mapping: :inout_required}
      ],
      deductions: [
        %{
          branches: [
            %{
              conditions: [],
              assignments: [
                %{
                  target: :a0,
                  expression: {:and, [], [{:var, [], [:a0]}, {:var, [], [:b0]}]}
                },
                %{
                  target: :b0,
                  expression: {:or, [], [{:var, [], [:a0]}, {:var, [], [:b0]}]}
                }
              ]
            }
          ]
        }
      ]
    }
  end

  blueprint(:date_test) do
    %{
      variables: [
        %{name: :birthdate, type: :date, mapping: :in_required},
        %{name: :now, type: :date, mapping: :out},
        %{name: :date, type: :date, mapping: :out},
        %{name: :age, type: :integer, mapping: :out}
      ],
      deductions: [
        %{
          branches: [
            %{
              conditions: [],
              assignments: [
                %{target: :now, expression: quote(do: now())},
                %{target: :age, expression: quote(do: age(@birthdate))},
                %{target: :date, expression: "2010-05-02"}
              ]
            }
          ]
        },
        %{
          branches: [
            %{
              conditions: [],
              assignments: [
                %{target: :date, expression: quote(do: add_days(@date, 5))}
              ]
            }
          ]
        }
      ]
    }
  end
end
