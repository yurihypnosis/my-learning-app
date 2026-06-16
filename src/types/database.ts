export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: { id: string; display_name: string | null; created_at: string; updated_at: string };
        Insert: { id: string; display_name?: string | null };
        Update: { display_name?: string | null };
        Relationships: [];
      };
      subjects: {
        Row: {
          id: string;
          slug: string;
          name: string;
          description: string | null;
          color: string;
          sort_order: number;
          is_active: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: { slug: string; name: string; description?: string | null; color?: string; sort_order?: number; is_active?: boolean };
        Update: { slug?: string; name?: string; description?: string | null; color?: string; sort_order?: number; is_active?: boolean };
        Relationships: [];
      };
      categories: {
        Row: {
          id: string;
          subject_id: string;
          name: string;
          color: string;
          sort_order: number;
          created_at: string;
          updated_at: string;
        };
        Insert: { subject_id: string; name: string; color?: string; sort_order?: number };
        Update: { name?: string; color?: string; sort_order?: number };
        Relationships: [
          {
            foreignKeyName: "categories_subject_id_fkey";
            columns: ["subject_id"];
            isOneToOne: false;
            referencedRelation: "subjects";
            referencedColumns: ["id"];
          },
        ];
      };
      questions: {
        Row: {
          id: string;
          subject_id: string;
          category_id: string;
          source_ref: string | null;
          question_text: string;
          options: Json;
          correct_index: number;
          explanation: string;
          initial_wrong_weight: number;
          is_active: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          subject_id: string;
          category_id: string;
          source_ref?: string | null;
          question_text: string;
          options: Json;
          correct_index: number;
          explanation?: string;
          initial_wrong_weight?: number;
          is_active?: boolean;
        };
        Update: {
          question_text?: string;
          options?: Json;
          correct_index?: number;
          explanation?: string;
          initial_wrong_weight?: number;
          is_active?: boolean;
        };
        Relationships: [
          {
            foreignKeyName: "questions_category_id_fkey";
            columns: ["category_id"];
            isOneToOne: false;
            referencedRelation: "categories";
            referencedColumns: ["id"];
          },
        ];
      };
      user_question_progress: {
        Row: {
          id: string;
          user_id: string;
          question_id: string;
          correct_count: number;
          wrong_count: number;
          consecutive_correct: number;
          last_is_correct: boolean | null;
          last_selected_index: number | null;
          last_answered_at: string | null;
          understanding_level: number;
          memo: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          user_id: string;
          question_id: string;
          correct_count?: number;
          wrong_count?: number;
          consecutive_correct?: number;
          last_is_correct?: boolean | null;
          last_selected_index?: number | null;
          last_answered_at?: string | null;
          understanding_level?: number;
          memo?: string;
        };
        Update: {
          correct_count?: number;
          wrong_count?: number;
          consecutive_correct?: number;
          last_is_correct?: boolean | null;
          last_selected_index?: number | null;
          last_answered_at?: string | null;
          understanding_level?: number;
          memo?: string;
        };
        Relationships: [
          {
            foreignKeyName: "user_question_progress_question_id_fkey";
            columns: ["question_id"];
            isOneToOne: false;
            referencedRelation: "questions";
            referencedColumns: ["id"];
          },
        ];
      };
    };
    Views: { [_ in never]: never };
    Functions: { [_ in never]: never };
    Enums: { [_ in never]: never };
    CompositeTypes: { [_ in never]: never };
  };
}

export type Tables<T extends keyof Database["public"]["Tables"]> =
  Database["public"]["Tables"][T]["Row"];
export type InsertTables<T extends keyof Database["public"]["Tables"]> =
  Database["public"]["Tables"][T]["Insert"];
export type UpdateTables<T extends keyof Database["public"]["Tables"]> =
  Database["public"]["Tables"][T]["Update"];
