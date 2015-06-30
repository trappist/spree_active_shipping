module Spree
  module ActiveShipping
    module FedExOverride
      def self.included(base)

        base.class_eval do

          def shipping_options(package)
            if signature_type = Spree::ActiveShipping::Config[:fedex_signature_type]
              if signature_threshold = Spree::ActiveShipping::Config[:fedex_signature_threshold]
                if signature_threshold > 0 and signature_threshold < package.order.total
                  return {signature_option: signature_type.to_sym}
                end
              end
            end
            {}
          end

          def build_packages_nodes(xml, packages, imperial)
            puts '========='
            puts "#{packages.size} packages"
            puts '========='
            packages.map do |pkg|
              xml.RequestedPackageLineItems do
                options = shipping_options(pkg)
                if options.has_key?(:signature_option)
                  xml.SpecialServicesRequested do
                    xml.SpecialServiceTypes("SIGNATURE_OPTION")
                    xml.SignatureOptionDetail do
                      xml.OptionType(::ActiveShipping::FedEx::SIGNATURE_OPTION_CODES[options[:signature_option] || :default_for_service])
                    end
                  end
                end
                xml.GroupPackageCount(1)
                build_package_weight_node(xml, pkg, imperial)
                build_package_dimensions_node(xml, pkg, imperial)
              end
            end
          end

        end

      end

    end
  end
end
