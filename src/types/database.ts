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
          code: string | null;
          options: Json;
          correct_index: number;
          correct_indices: Json | null;
          question_type: string;
          explanation: string;
          explanation_data: Json | null;
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
          code?: string | null;
          options: Json;
          correct_index: number;
          correct_indices?: Json | null;
          question_type?: string;
          explanation?: string;
          explanation_data?: Json | null;
          initial_wrong_weight?: number;
          is_active?: boolean;
        };
        Update: {
          question_text?: string;
          code?: string | null;
          options?: Json;
          correct_index?: number;
          correct_indices?: Json | null;
          question_type?: string;
          explanation?: string;
          explanation_data?: Json | null;
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
      answer_events: {
        Row: {
          id: string;
          user_id: string;
          question_id: string;
          category_id: string;
          category_name: string;
          category_color: string;
          subject_slug: string;
          is_correct: boolean;
          confidence: number | null;
          answered_at: string;
        };
        Insert: {
          user_id: string;
          question_id: string;
          category_id: string;
          category_name: string;
          category_color?: string;
          subject_slug: string;
          is_correct: boolean;
          confidence?: number | null;
          answered_at?: string;
        };
        Update: {
          is_correct?: boolean;
          confidence?: number | null;
        };
        Relationships: [];
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
          last_confidence: number | null;
          last_spoken_ok: boolean | null;
          fsrs_stability: number | null;
          fsrs_difficulty: number | null;
          fsrs_due: string | null;
          fsrs_last_review: string | null;
          fsrs_reps: number;
          fsrs_lapses: number;
          fsrs_state: string;
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
          last_confidence?: number | null;
          last_spoken_ok?: boolean | null;
          fsrs_stability?: number | null;
          fsrs_difficulty?: number | null;
          fsrs_due?: string | null;
          fsrs_last_review?: string | null;
          fsrs_reps?: number;
          fsrs_lapses?: number;
          fsrs_state?: string;
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
          last_confidence?: number | null;
          last_spoken_ok?: boolean | null;
          fsrs_stability?: number | null;
          fsrs_difficulty?: number | null;
          fsrs_due?: string | null;
          fsrs_last_review?: string | null;
          fsrs_reps?: number;
          fsrs_lapses?: number;
          fsrs_state?: string;
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
      user_exam_goals: {
        Row: {
          user_id: string;
          exam_key: string;
          exam_date: string | null;
          target_name: string;
          updated_at: string;
        };
        Insert: {
          user_id: string;
          exam_key: string;
          exam_date?: string | null;
          target_name?: string;
        };
        Update: {
          exam_date?: string | null;
          target_name?: string;
        };
        Relationships: [];
      };
      flashcard_events: {
        Row: {
          id: string;
          user_id: string;
          deck_key: string;
          cat: string;
          category_color: string;
          result: string;
          answered_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          deck_key: string;
          cat: string;
          category_color?: string;
          result: string;
          answered_at?: string;
        };
        Update: {
          result?: string;
        };
        Relationships: [];
      };
      user_term_progress: {
        Row: {
          user_id: string;
          deck_key: string;
          term: string;
          result: string;
          known_count: number;
          weak_count: number;
          updated_at: string;
        };
        Insert: {
          user_id: string;
          deck_key: string;
          term: string;
          result: string;
          known_count?: number;
          weak_count?: number;
        };
        Update: {
          result?: string;
          known_count?: number;
          weak_count?: number;
        };
        Relationships: [];
      };
      user_textbooks: {
        Row: {
          id: string;
          user_id: string;
          exam_key: string;
          label: string;
          url: string;
          sort_order: number;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          exam_key: string;
          label?: string;
          url: string;
          sort_order?: number;
        };
        Update: {
          label?: string;
          url?: string;
          sort_order?: number;
        };
        Relationships: [];
      };
      user_roadmap_items: {
        Row: {
          user_id: string;
          item_key: string;
          done: boolean;
          updated_at: string;
        };
        Insert: {
          user_id: string;
          item_key: string;
          done?: boolean;
        };
        Update: {
          done?: boolean;
        };
        Relationships: [];
      };
      user_roadmap: {
        Row: {
          user_id: string;
          doc: Json;
          updated_at: string;
        };
        Insert: {
          user_id: string;
          doc?: Json;
        };
        Update: {
          doc?: Json;
        };
        Relationships: [];
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
