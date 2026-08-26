export type { Dispatch, SetStateAction } from "react";
export type {
  MiqFormSchemaType,
  OptionType,
  FormOptions,
} from "@@miq-types/forms";

type SupportedProvidersType = {
  title: string;
  type: string;
  kind: string;
  regions?: Array<{
    name: string;
    description?: string;
  }>;
};

export type ProvidersResponse = {
  data: {
    supported_providers: SupportedProvidersType[];
  };
};

type ResourceType = {
  href: string;
  id: string;
  name: string;
  type: string;
};

export type ResourcesResponseType = {
  resources: ResourceType[];
};

export type FormState = {
  src_provider_id?: string;
  obj_storage_id?: string;
};

export type FormValues = {
  src_provider_id?: string;
  src_image_id?: string;
  obj_storage_id?: string;
  bucket_id?: string;
  disk_type_id?: string;
  timeout?: number;
  keep_ova?: boolean;
};
