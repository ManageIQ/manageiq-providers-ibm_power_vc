module ManageIQ
  module Providers
    module IbmPowerVc
      module ToolbarOverrides
        class EmsCloudCenter < ::ApplicationHelper::Toolbar::Override
          button_group('pvc_image_import_group', [
                         button(
                           :pvc_import_image,
                           'pficon pficon-import fa-lg',
                           t = N_('Import Image'),
                           t,
                           :data  => {'function'      => 'sendDataWithRx',
                                      'function-data' => {:controller     => 'provider_dialogs',
                                                          :button         => :pvc_import_image,
                                                          :modal_title    => N_('Image Import Workflow'),
                                                          :component_name => 'PvcImportImageForm'}},
                           :klass => ::ApplicationHelper::Button::ButtonWithoutRbacCheck
                         ),
                       ])
        end
      end
    end
  end
end
